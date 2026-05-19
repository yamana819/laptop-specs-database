package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.laptopdb.backend.dto.DisplayResponse;
import com.laptopdb.backend.entity.Display;
import com.laptopdb.backend.exception.ResourceNotFoundException;
import com.laptopdb.backend.repository.DisplayRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class DisplayServiceImpl implements DisplayService {

    private final DisplayRepository displayRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<DisplayResponse> findAll(Pageable pageable) {
        return displayRepository.findAll(pageable).map(DisplayResponse::from);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DisplayResponse> findAllList() {
        return displayRepository.findAll().stream().map(DisplayResponse::from).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DisplayResponse getById(Integer id) {
        Display display = displayRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Display", id));
        return DisplayResponse.from(display);
    }

    @Override
    @Transactional
    public DisplayResponse create(Display display) {
        return DisplayResponse.from(displayRepository.save(display));
    }

    @Override
    @Transactional
    public DisplayResponse update(Integer id, Display incoming) {
        Display existing = displayRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Display", id));
        
        existing.setSizeInch(incoming.getSizeInch());
        existing.setResolution(incoming.getResolution());
        existing.setRefreshRateHz(incoming.getRefreshRateHz());
        existing.setPanelType(incoming.getPanelType());
        
        return DisplayResponse.from(displayRepository.save(existing));
    }

    @Override
    @Transactional
    public void delete(Integer id) {
        if (!displayRepository.existsById(id)) {
            throw new ResourceNotFoundException("Display", id);
        }
        displayRepository.deleteById(id);
    }
}