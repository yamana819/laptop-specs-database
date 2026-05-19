package com.laptopdb.backend.services;

import com.laptopdb.backend.dto.GpuResponse;
import com.laptopdb.backend.entity.Gpu;
import com.laptopdb.backend.exception.ResourceNotFoundException;
import com.laptopdb.backend.repository.GpuRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class GpuServiceImpl implements GpuService {

    private final GpuRepository gpuRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<GpuResponse> findAll(Pageable pageable) {
        return gpuRepository.findAll(pageable).map(GpuResponse::from);
    }

    @Override
    @Transactional(readOnly = true)
    public List<GpuResponse> findAllList() {
        return gpuRepository.findAll().stream().map(GpuResponse::from).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public GpuResponse getById(Integer id) {
        Gpu gpu = gpuRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("GPU", id));
        return GpuResponse.from(gpu);
    }

    @Override
    @Transactional
    public GpuResponse create(Gpu gpu) {
        return GpuResponse.from(gpuRepository.save(gpu));
    }

    @Override
    @Transactional
    public GpuResponse update(Integer id, Gpu incoming) {
        Gpu existing = gpuRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("GPU", id));
        
        existing.setBrand(incoming.getBrand());
        existing.setModelName(incoming.getModelName());
        existing.setVramGb(incoming.getVramGb());
        
        return GpuResponse.from(gpuRepository.save(existing));
    }

    @Override
    @Transactional
    public void delete(Integer id) {
        if (!gpuRepository.existsById(id)) {
            throw new ResourceNotFoundException("GPU", id);
        }
        gpuRepository.deleteById(id);
    }
}