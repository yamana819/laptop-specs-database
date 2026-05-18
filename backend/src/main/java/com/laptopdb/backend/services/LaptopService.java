package com.laptopdb.backend.services;

import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.laptopdb.backend.dto.LaptopFilterRequest;
import com.laptopdb.backend.dto.LaptopResponse;
import com.laptopdb.backend.entity.Laptop;

public interface LaptopService {
    Page<LaptopResponse> findAll(LaptopFilterRequest filter, Pageable pageable);
    LaptopResponse getById(Integer id);
    LaptopResponse create(Laptop laptop);
    LaptopResponse update(Integer id, Laptop laptop);
    LaptopResponse patch(Integer id, Map<String, Object> fields);
    void delete(Integer id);
    List<String> getDistinctBrands();
    List<String> getDistinctGpuModels();
    List<LaptopResponse> applyGpuTierFilter(List<LaptopResponse> laptops, Integer minGpuTier);
}