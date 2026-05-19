package com.laptopdb.backend.services;

import com.laptopdb.backend.dto.CpuResponse;
import com.laptopdb.backend.entity.Cpu;
import com.laptopdb.backend.exception.ResourceNotFoundException;
import com.laptopdb.backend.repository.CpuRepository;
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
public class CpuServiceImpl implements CpuService {

    private final CpuRepository cpuRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<CpuResponse> findAll(Pageable pageable) {
        return cpuRepository.findAll(pageable).map(CpuResponse::from);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CpuResponse> findAllList() {
        return cpuRepository.findAll().stream().map(CpuResponse::from).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CpuResponse getById(Integer id) {
        Cpu cpu = cpuRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("CPU", id));
        return CpuResponse.from(cpu);
    }

    @Override
    @Transactional
    public CpuResponse create(Cpu cpu) {
        return CpuResponse.from(cpuRepository.save(cpu));
    }

    @Override
    @Transactional
    public CpuResponse update(Integer id, Cpu incoming) {
        Cpu existing = cpuRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("CPU", id));
        
        existing.setBrand(incoming.getBrand());
        existing.setSeries(incoming.getSeries());
        existing.setModelName(incoming.getModelName());
        existing.setCoreCount(incoming.getCoreCount());
        existing.setThreadCount(incoming.getThreadCount());
        existing.setCacheMb(incoming.getCacheMb());
        existing.setBaseClockGhz(incoming.getBaseClockGhz());
        existing.setBoostClockGhz(incoming.getBoostClockGhz());
        
        return CpuResponse.from(cpuRepository.save(existing));
    }

    @Override
    @Transactional
    public void delete(Integer id) {
        if (!cpuRepository.existsById(id)) {
            throw new ResourceNotFoundException("CPU", id);
        }
        cpuRepository.deleteById(id);
    }
}