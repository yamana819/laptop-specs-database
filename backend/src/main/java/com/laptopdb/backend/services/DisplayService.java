package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.laptopdb.backend.entity.Display;
import com.laptopdb.backend.repository.DisplayRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DisplayService {

    private final DisplayRepository displayRepository;

    public Display saveDisplay(Display display) {
        return displayRepository.save(display);
    }

    public List<Display> getAllDisplays() {
        return displayRepository.findAll();
    }

    public Display getDisplayById(Integer id) {
        return displayRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Display not found with id: " + id));
    }

    public Display updateDisplay(Integer id, Display updatedDisplay) {
        Display existingDisplay = getDisplayById(id);

        existingDisplay.setSizeInch(updatedDisplay.getSizeInch());
        existingDisplay.setResolution(updatedDisplay.getResolution());
        existingDisplay.setRefreshRateHz(updatedDisplay.getRefreshRateHz());
        existingDisplay.setPanelType(updatedDisplay.getPanelType());
        existingDisplay.setBrightnessNits(updatedDisplay.getBrightnessNits());

        return displayRepository.save(existingDisplay);
    }

    public void deleteDisplay(Integer id) {
        if (!displayRepository.existsById(id)) {
            throw new RuntimeException("Cannot delete. Display not found with id: " + id);
        }
        displayRepository.deleteById(id);
    }
}