package com.laptopdb.backend.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.laptopdb.backend.entity.Gpu;
import com.laptopdb.backend.repository.GpuRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GpuService {

    private final GpuRepository gpuRepository;

    public Gpu saveGpu(Gpu gpu) {
        return gpuRepository.save(gpu);
    }

    public List<Gpu> getAllGpus() {
        return gpuRepository.findAll();
    }

    public Gpu getGpuById(Integer id) {
        return gpuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("GPU not found with id: " + id));
    }

    public Gpu updateGpu(Integer id, Gpu updatedGpu) {
        Gpu existingGpu = getGpuById(id);

        existingGpu.setBrand(updatedGpu.getBrand());
        existingGpu.setModelName(updatedGpu.getModelName());
        existingGpu.setTdpWatt(updatedGpu.getTdpWatt()); 
        existingGpu.setVramGb(updatedGpu.getVramGb());
        existingGpu.setVramType(updatedGpu.getVramType());
        existingGpu.setMemoryBusBit(updatedGpu.getMemoryBusBit());

        return gpuRepository.save(existingGpu);
    }

    public void deleteGpu(Integer id) {
        if (!gpuRepository.existsById(id)) {
            throw new RuntimeException("Cannot delete. GPU not found with id: " + id);
        }
        gpuRepository.deleteById(id);
    }
}