package com.laptopdb.backend.dto;

import com.laptopdb.backend.entity.Gpu;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class GpuResponse {

    private final Integer id;
    private final String brand;
    private final String modelName;
    private final Integer vramGb;

    public static GpuResponse from(Gpu gpu) {
        return GpuResponse.builder()
                .id(gpu.getId())
                .brand(gpu.getBrand())
                .modelName(gpu.getModelName())
                .vramGb(gpu.getVramGb())
                .build();
    }
}