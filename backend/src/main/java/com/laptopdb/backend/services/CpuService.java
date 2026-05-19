package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.laptopdb.backend.dto.CpuResponse;
import com.laptopdb.backend.entity.Cpu;

public interface CpuService {
    Page<CpuResponse> findAll(Pageable pageable);
    List<CpuResponse> findAllList();
    CpuResponse getById(Integer id);
    CpuResponse create(Cpu cpu);
    CpuResponse update(Integer id, Cpu cpu);
    void delete(Integer id);
}