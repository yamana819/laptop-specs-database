package com.laptopdb.backend.dto;

import java.math.BigDecimal;

import com.laptopdb.backend.entity.Display;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class DisplayResponse {

    private final Integer id;
    private final BigDecimal sizeInch;
    private final String resolution;
    private final Integer refreshRateHz;
    private final String panelType;

    public static DisplayResponse from(Display display) {
        return DisplayResponse.builder()
                .id(display.getId())
                .sizeInch(display.getSizeInch())
                .resolution(display.getResolution())
                .refreshRateHz(display.getRefreshRateHz())
                .panelType(display.getPanelType())
                .build();
    }
}