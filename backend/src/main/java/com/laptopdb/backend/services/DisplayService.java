package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.laptopdb.backend.dto.DisplayResponse;
import com.laptopdb.backend.entity.Display;

public interface DisplayService {
    Page<DisplayResponse> findAll(Pageable pageable);
    List<DisplayResponse> findAllList();
    DisplayResponse getById(Integer id);
    DisplayResponse create(Display display);
    DisplayResponse update(Integer id, Display display);
    void delete(Integer id);
}