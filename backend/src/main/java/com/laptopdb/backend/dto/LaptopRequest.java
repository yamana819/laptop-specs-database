package com.laptopdb.backend.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LaptopRequest {

    @NotBlank(message = "Brand cannot be blank")
    private String brand;

    @NotBlank(message = "Series cannot be blank")
    private String series;

    @NotNull(message = "CPU ID cannot be null")
    private Integer cpuId;

    @NotNull(message = "GPU ID cannot be null")
    private Integer gpuId;

    @NotNull(message = "Display ID cannot be null")
    private Integer displayId;

    @NotNull(message = "RAM capacity cannot be null")
    private Integer ramCapacityGb;

    @NotNull(message = "RAM speed cannot be null")
    private Integer ramSpeedMhz;

    @NotBlank(message = "RAM type cannot be blank")
    private String ramType;

    @NotNull(message = "Storage capacity cannot be null")
    private Integer storageCapacityGb;

    @NotBlank(message = "Storage type cannot be blank")
    private String storageType;

    private BigDecimal weightKg;

    @NotNull(message = "Thickness cannot be null")
    private BigDecimal thicknessMm;

    @NotNull(message = "Battery capacity cannot be null")
    private Integer batteryWh;

    private String wifiVersion;
    private String bluetoothVersion;
}