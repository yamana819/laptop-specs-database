package com.laptopdb.backend.services;

import com.laptopdb.backend.dto.LaptopFilterRequest;
import com.laptopdb.backend.dto.LaptopResponse;
import com.laptopdb.backend.entity.Laptop;
import com.laptopdb.backend.exception.ResourceNotFoundException;
import com.laptopdb.backend.repository.LaptopRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ReflectionUtils;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class LaptopServiceImpl implements LaptopService {

    private final LaptopRepository laptopRepository;
    private final EntityManager entityManager;
    private static final Pattern GPU_TIER_PATTERN = Pattern.compile("(\\d{4})");

    @Override
    @Transactional(readOnly = true)
    public Page<LaptopResponse> findAll(LaptopFilterRequest f, Pageable pageable) {
        log.debug("findAll called with filter: {}", f);

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Laptop> query = cb.createQuery(Laptop.class);
        Root<Laptop> root = query.from(Laptop.class);

        root.fetch("cpu", JoinType.LEFT);
        root.fetch("gpu", JoinType.LEFT);
        root.fetch("display", JoinType.LEFT);

        List<Predicate> predicates = buildPredicates(f, cb, root);
        query.where(cb.and(predicates.toArray(new Predicate[0])));

        if (pageable.getSort().isSorted()) {
            List<Order> orders = new ArrayList<>();
            pageable.getSort().forEach(order -> {
                if (order.isAscending()) {
                    orders.add(cb.asc(root.get(order.getProperty())));
                } else {
                    orders.add(cb.desc(root.get(order.getProperty())));
                }
            });
            query.orderBy(orders);
        }

        List<Laptop> content = entityManager.createQuery(query)
                .setFirstResult((int) pageable.getOffset())
                .setMaxResults(pageable.getPageSize())
                .getResultList();

        long total = countAll(f);

        List<LaptopResponse> dtos = content.stream()
                .map(LaptopResponse::from)
                .toList();

        if (f.getMinGpuTier() != null) {
            dtos = applyGpuTierFilter(dtos, f.getMinGpuTier());
        }

        return new PageImpl<>(dtos, pageable, total);
    }

    @Override
    @Transactional(readOnly = true)
    public LaptopResponse getById(Integer id) {
        Laptop laptop = findOrThrow(id);
        return LaptopResponse.from(laptop);
    }

    @Override
    @Transactional
    public LaptopResponse create(Laptop laptop) {
        Laptop saved = laptopRepository.save(laptop);
        log.info("Created laptop id={}", saved.getId());
        return LaptopResponse.from(saved);
    }

    @Override
    @Transactional
    public LaptopResponse update(Integer id, Laptop incoming) {
        findOrThrow(id);
        incoming.setId(id);
        Laptop saved = laptopRepository.save(incoming);
        log.info("Updated (PUT) laptop id={}", id);
        return LaptopResponse.from(saved);
    }

    @Override
    @Transactional
    public LaptopResponse patch(Integer id, Map<String, Object> fields) {
        Laptop laptop = findOrThrow(id);
        fields.forEach((key, value) -> {
            Field field = ReflectionUtils.findField(Laptop.class, key);
            if (field != null) {
                field.setAccessible(true);
                ReflectionUtils.setField(field, laptop, value);
            } else {
                log.warn("PATCH: unknown field '{}' ignored", key);
            }
        });
        Laptop saved = laptopRepository.save(laptop);
        log.info("Patched laptop id={}", id);
        return LaptopResponse.from(saved);
    }

    @Override
    @Transactional
    public void delete(Integer id) {
        findOrThrow(id);
        laptopRepository.deleteById(id);
        log.info("Deleted laptop id={}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getDistinctBrands() {
        return laptopRepository.findDistinctBrands();
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getDistinctGpuModels() {
        return laptopRepository.findDistinctGpuModels();
    }

    private Laptop findOrThrow(Integer id) {
        return laptopRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Laptop", id));
    }

    private List<Predicate> buildPredicates(LaptopFilterRequest f, CriteriaBuilder cb, Root<Laptop> root) {
        List<Predicate> list = new ArrayList<>();

        if (f.getBrand() != null && !f.getBrand().isBlank()) {
            list.add(cb.equal(cb.lower(root.get("brand").as(String.class)), f.getBrand().toLowerCase()));
        }

        if (f.getSeries() != null && !f.getSeries().isBlank()) {
            list.add(cb.like(cb.lower(root.get("series").as(String.class)), "%" + f.getSeries().toLowerCase() + "%"));
        }

        if (f.getMinRamGb() != null) {
            list.add(cb.greaterThanOrEqualTo(root.get("ramCapacityGb").as(Integer.class), f.getMinRamGb()));
        }
        if (f.getMaxRamGb() != null) {
            list.add(cb.lessThanOrEqualTo(root.get("ramCapacityGb").as(Integer.class), f.getMaxRamGb()));
        }
        if (f.getRamType() != null && !f.getRamType().isBlank()) {
            list.add(cb.equal(cb.lower(root.get("ramType").as(String.class)), f.getRamType().toLowerCase()));
        }

        if (f.getMinStorageGb() != null) {
            list.add(cb.greaterThanOrEqualTo(root.get("storageCapacityGb").as(Integer.class), f.getMinStorageGb()));
        }
        if (f.getStorageType() != null && !f.getStorageType().isBlank()) {
            list.add(cb.like(cb.lower(root.get("storageType").as(String.class)), "%" + f.getStorageType().toLowerCase() + "%"));
        }

        if (f.getMinBatteryWh() != null) {
            list.add(cb.greaterThanOrEqualTo(root.get("batteryWh").as(Integer.class), f.getMinBatteryWh()));
        }

        if (f.getMaxWeightKg() != null) {
            list.add(cb.lessThanOrEqualTo(root.get("weightKg").as(BigDecimal.class), f.getMaxWeightKg()));
        }

        Join<?, ?> cpu = root.join("cpu", JoinType.LEFT);
        if (f.getCpuBrand() != null && !f.getCpuBrand().isBlank()) {
            list.add(cb.equal(cb.lower(cpu.get("brand").as(String.class)), f.getCpuBrand().toLowerCase()));
        }
        if (f.getCpuSeries() != null && !f.getCpuSeries().isBlank()) {
            list.add(cb.like(cb.lower(cpu.get("series").as(String.class)), "%" + f.getCpuSeries().toLowerCase() + "%"));
        }
        if (f.getMinCoreCount() != null) {
            list.add(cb.greaterThanOrEqualTo(cpu.get("coreCount").as(Integer.class), f.getMinCoreCount()));
        }

        Join<?, ?> gpu = root.join("gpu", JoinType.LEFT);
        if (f.getGpuBrand() != null && !f.getGpuBrand().isBlank()) {
            list.add(cb.equal(cb.lower(gpu.get("brand").as(String.class)), f.getGpuBrand().toLowerCase()));
        }
        if (f.getMinVramGb() != null) {
            list.add(cb.greaterThanOrEqualTo(gpu.get("vramGb").as(Integer.class), f.getMinVramGb()));
        }

        Join<?, ?> display = root.join("display", JoinType.LEFT);
        if (f.getMinDisplayInch() != null) {
            list.add(cb.greaterThanOrEqualTo(display.get("sizeInch").as(BigDecimal.class), f.getMinDisplayInch()));
        }
        if (f.getMaxDisplayInch() != null) {
            list.add(cb.lessThanOrEqualTo(display.get("sizeInch").as(BigDecimal.class), f.getMaxDisplayInch()));
        }
        if (f.getMinRefreshRateHz() != null) {
            list.add(cb.greaterThanOrEqualTo(display.get("refreshRateHz").as(Integer.class), f.getMinRefreshRateHz()));
        }
        if (f.getResolution() != null && !f.getResolution().isBlank()) {
            list.add(cb.equal(display.get("resolution").as(String.class), f.getResolution()));
        }
        if (f.getPanelType() != null && !f.getPanelType().isBlank()) {
            list.add(cb.equal(cb.lower(display.get("panelType").as(String.class)), f.getPanelType().toLowerCase()));
        }

        return list;
    }

    @Override
    public List<LaptopResponse> applyGpuTierFilter(List<LaptopResponse> list, Integer minGpuTier) {
        if (minGpuTier == null)
            return list;
        return list.stream()
                .filter(lr -> {
                    if (lr.getGpuModelName() == null)
                        return false;
                    Matcher m = GPU_TIER_PATTERN.matcher(lr.getGpuModelName());
                    if (m.find()) {
                        int tier = Integer.parseInt(m.group(1));
                        return tier >= minGpuTier;
                    }
                    return false;
                })
                .toList();
    }

    private long countAll(LaptopFilterRequest f) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> cq = cb.createQuery(Long.class);
        Root<Laptop> root = cq.from(Laptop.class);
        List<Predicate> preds = buildPredicates(f, cb, root);
        cq.select(cb.count(root)).where(cb.and(preds.toArray(new Predicate[0])));
        return entityManager.createQuery(cq).getSingleResult();
    }
}