package com.laptopdb.backend.dto;

import java.math.BigDecimal;

import lombok.Data;
@Data
public class LaptopFilterRequest {
    private String brand;
    private String series;
    private String gpuBrand;
    private Integer minVramGb;
    private Integer minGpuTier;
    private String cpuBrand;
    private String cpuSeries;
    private Integer minCoreCount;
    private Integer minRamGb;
    private Integer maxRamGb;
    private String ramType;
    private Integer minStorageGb;
    private String storageType;
    private BigDecimal minDisplayInch;
    private BigDecimal maxDisplayInch;
    private Integer minRefreshRateHz;
    private String resolution;
    private String panelType;

    private BigDecimal maxWeightKg;

    private Integer minBatteryWh;
}