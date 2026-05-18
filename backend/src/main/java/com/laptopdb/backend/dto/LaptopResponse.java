package com.laptopdb.backend.dto;

import java.math.BigDecimal;

import com.laptopdb.backend.entity.Laptop;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LaptopResponse {

    private final Integer id;
    private final String brand;
    private final String series;

    private final String cpuBrand;
    private final String cpuSeries;
    private final String cpuModelName;
    private final Integer cpuCoreCount;
    private final Integer cpuThreadCount; 
    private final Integer cpuCacheMb;     
    private final BigDecimal cpuBaseClockGhz;
    private final BigDecimal cpuBoostClockGhz;

    private final String gpuBrand;
    private final String gpuModelName;
    private final Integer gpuTdpWatt;      
    private final Integer gpuVramGb;
    private final String gpuVramType;
    private final Integer gpuMemoryBusBit; 

    private final BigDecimal displaySizeInch;
    private final String displayResolution;
    private final Integer displayRefreshRateHz;
    private final String displayPanelType;
    private final Integer displayBrightnessNits;

    private final Integer ramCapacityGb;
    private final Integer ramSpeedMhz;
    private final String ramType;

    private final Integer storageCapacityGb;
    private final String storageType;

    private final BigDecimal weightKg;
    private final BigDecimal thicknessMm;
    private final Integer batteryWh;

    private final String wifiVersion;
    private final String bluetoothVersion;

    public static LaptopResponse from(Laptop laptop) {
        return LaptopResponse.builder()
                .id(laptop.getId())
                .brand(laptop.getBrand())
                .series(laptop.getSeries())

                .cpuBrand(laptop.getCpu().getBrand())
                .cpuSeries(laptop.getCpu().getSeries())
                .cpuModelName(laptop.getCpu().getModelName())
                .cpuCoreCount(laptop.getCpu().getCoreCount())
                .cpuThreadCount(laptop.getCpu().getThreadCount()) 
                .cpuCacheMb(laptop.getCpu().getCacheMb())         
                .cpuBaseClockGhz(laptop.getCpu().getBaseClockGhz())
                .cpuBoostClockGhz(laptop.getCpu().getBoostClockGhz())

                .gpuBrand(laptop.getGpu().getBrand())
                .gpuModelName(laptop.getGpu().getModelName())
                .gpuTdpWatt(laptop.getGpu().getTdpWatt())         
                .gpuVramGb(laptop.getGpu().getVramGb())
                .gpuVramType(laptop.getGpu().getVramType())
                .gpuMemoryBusBit(laptop.getGpu().getMemoryBusBit()) 

                .displaySizeInch(laptop.getDisplay().getSizeInch())
                .displayResolution(laptop.getDisplay().getResolution())
                .displayRefreshRateHz(laptop.getDisplay().getRefreshRateHz())
                .displayPanelType(laptop.getDisplay().getPanelType())
                .displayBrightnessNits(laptop.getDisplay().getBrightnessNits())

                .ramCapacityGb(laptop.getRamCapacityGb())
                .ramSpeedMhz(laptop.getRamSpeedMhz())
                .ramType(laptop.getRamType())
                .storageCapacityGb(laptop.getStorageCapacityGb())
                .storageType(laptop.getStorageType())
                .weightKg(laptop.getWeightKg())
                .thicknessMm(laptop.getThicknessMm())
                .batteryWh(laptop.getBatteryWh())
                .wifiVersion(laptop.getWifiVersion())
                .bluetoothVersion(laptop.getBluetoothVersion())
                .build();
    }
}