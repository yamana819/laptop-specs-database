package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.laptopdb.backend.entity.Cpu;
import com.laptopdb.backend.repository.CpuRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CpuService {

    private final CpuRepository cpuRepository;

    public Cpu saveCpu(Cpu cpu) {
        return cpuRepository.save(cpu);
    }

    public List<Cpu> getAllCpus() {
        return cpuRepository.findAll();
    }

    public Cpu getCpuById(Integer id) {
        return cpuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("CPU not found with id: " + id));
    }

    public Cpu updateCpu(Integer id, Cpu updatedCpu) {
        Cpu existingCpu = getCpuById(id);
        
        existingCpu.setBrand(updatedCpu.getBrand());
        existingCpu.setSeries(updatedCpu.getSeries());
        existingCpu.setModelName(updatedCpu.getModelName()); 
        existingCpu.setBaseClockGhz(updatedCpu.getBaseClockGhz());
        existingCpu.setBoostClockGhz(updatedCpu.getBoostClockGhz());
        existingCpu.setCoreCount(updatedCpu.getCoreCount());
        existingCpu.setThreadCount(updatedCpu.getThreadCount());
        existingCpu.setCacheMb(updatedCpu.getCacheMb());

        return cpuRepository.save(existingCpu);
    }

    public void deleteCpu(Integer id) {
        if (!cpuRepository.existsById(id)) {
            throw new RuntimeException("Cannot delete. CPU not found with id: " + id);
        }
        cpuRepository.deleteById(id);
    }
}