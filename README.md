# Credit Risk & Loss Forecasting Engine

**Thesis:** A model is only as good as its ability to survive uncertainty. This project builds a production-grade credit risk system that predicts the probability of default, forecasts expected financial loss, and quantifies the uncertainty of those predictions.

## Architecture

1. **Advanced SQL Feature Pipeline** (`/sql`): Uses recursive CTEs and window functions to calculate rolling customer behavior metrics.
2. **Credit Risk Model** (`/models`): Calibrated XGBoost model with cost-sensitive thresholding.
3. **Forecasting Engine** (`/forecasting`): Time-series forecasting of Expected Loss (PD × LGD × EAD) with rolling-origin cross-validation.
4. **Rust Inference Engine** (`/rust-engine`): High-performance scoring API built in Rust.

## Status
- [x] Advanced SQL Feature Pipeline
- [x] Credit Risk Model (Calibrated XGBoost)
- [x] Forecasting Engine (Holt-Winters with 90% Confidence Intervals)
- [x] Rust Inference Engine (Low-latency scoring)

## The Senior-Level Signal
This project goes beyond predictive modeling. It includes:
1. **Time-Based Validation:** No random splits. The model is evaluated on future data.
2. **Probability Calibration:** The model outputs defensible probabilities, not just rankings.
3. **Cost-Sensitive Decisioning:** The threshold is optimized for the financial cost of false positives vs. false negatives.
4. **Uncertainty Quantification:** The forecast includes 90% prediction intervals, allowing risk committees to plan for worst-case scenarios.
5. **Systems Engineering:** The core inference is written in Rust to prove capability in low-latency environments.
