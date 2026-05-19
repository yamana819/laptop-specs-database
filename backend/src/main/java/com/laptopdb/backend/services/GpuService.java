package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.laptopdb.backend.dto.GpuResponse;
import com.laptopdb.backend.entity.Gpu;

public interface GpuService {
    Page<GpuResponse> findAll(Pageable pageable);
    List<GpuResponse> findAllList();
    GpuResponse getById(Integer id);
    GpuResponse create(Gpu gpu);
    GpuResponse update(Integer id, Gpu gpu);
    void delete(Integer id);
}