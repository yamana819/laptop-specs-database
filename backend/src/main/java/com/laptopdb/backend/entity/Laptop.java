package com.laptopdb.backend.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Entity
@Table(name = "laptops")
public class Laptop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Brand cannot be blank")
    @Column(nullable = false, length = 50)
    private String brand;

    @NotBlank(message = "Series cannot be blank")
    @Column(nullable = false, length = 100)
    private String series;

    @NotNull(message = "CPU cannot be null")
    @ManyToOne(optional = false)
    @JoinColumn(name = "cpu_id", nullable = false)
    private Cpu cpu;

    @NotNull(message = "GPU cannot be null")
    @ManyToOne(optional = false)
    @JoinColumn(name = "gpu_id", nullable = false)
    private Gpu gpu;

    @NotNull(message = "Display cannot be null")
    @ManyToOne(optional = false)
    @JoinColumn(name = "display_id", nullable = false)
    private Display display;


    @NotNull(message = "RAM capacity cannot be null")
    @Column(name = "ram_capacity_gb", nullable = false)
    private Integer ramCapacityGb;

    @NotNull(message = "RAM speed cannot be null")
    @Column(name = "ram_speed_mhz", nullable = false)
    private Integer ramSpeedMhz;

    @NotBlank(message = "RAM type cannot be blank")
    @Column(name = "ram_type", nullable = false, length = 20)
    private String ramType;

    @NotNull(message = "Storage capacity cannot be null")
    @Column(name = "storage_capacity_gb", nullable = false)
    private Integer storageCapacityGb;

    @NotBlank(message = "Storage type cannot be blank")
    @Column(name = "storage_type", nullable = false, length = 50)
    private String storageType;

    @Column(name = "weight_kg", precision = 4, scale = 2)
    private BigDecimal weightKg;

    @NotNull(message = "Thickness cannot be null")
    @Column(name = "thickness_mm", nullable = false, precision = 4, scale = 1)
    private BigDecimal thicknessMm;

    @NotNull(message = "Battery capacity cannot be null")
    @Column(name = "battery_wh", nullable = false)
    private Integer batteryWh;

    @Column(name = "wifi_version", length = 20)
    private String wifiVersion;

    @Column(name = "bluetooth_version", length = 10)
    private String bluetoothVersion;
}