package com.laptopdb.backend.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Entity
@Table(name = "displays")
public class Display {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull(message = "Display size cannot be null")
    @Column(name = "size_inch", nullable = false, precision = 3, scale = 1)
    private BigDecimal sizeInch;

    @NotBlank(message = "Resolution cannot be blank")
    @Column(nullable = false, length = 20)
    private String resolution;

    @NotNull(message = "Refresh rate cannot be null")
    @Column(name = "refresh_rate_hz", nullable = false)
    private Integer refreshRateHz;

    @NotBlank(message = "Panel type cannot be blank")
    @Column(name = "panel_type", nullable = false, length = 20)
    private String panelType;

    @Column(name = "brightness_nits")
    private Integer brightnessNits;
}