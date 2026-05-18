package com.laptopdb.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Entity
@Table(name = "gpus")
public class Gpu {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Brand cannot be blank")
    @Column(nullable = false, length = 50)
    private String brand;

    // ENGINEERING DECISION: UNIQUE constraint omitted to allow variants with different TDPs.
    @NotBlank(message = "Model name cannot be blank")
    @Column(name = "model_name", nullable = false, length = 100)
    private String modelName;

    // NULLABLE FIELDS: Can be left null for integrated graphics (e.g., Iris Xe).
    @Column(name = "tdp_watt")
    private Integer tdpWatt;

    @Column(name = "vram_gb")
    private Integer vramGb;

    @Column(name = "vram_type", length = 20)
    private String vramType;

    @Column(name = "memory_bus_bit")
    private Integer memoryBusBit;
}