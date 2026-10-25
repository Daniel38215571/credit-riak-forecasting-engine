# Credit Risk & Loss Forecasting Engine

**Thesis:** A model is only as good as its ability to survive uncertainty. This project builds a production-grade credit risk system that predicts the probability of default, forecasts expected financial loss, and quantifies the uncertainty of those predictions.

## Architecture

1. **Advanced SQL Feature Pipeline** (`/sql`): Uses recursive CTEs and window functions to calculate rolling customer behavior metrics.
2. **Credit Risk Model** (`/models`): Calibrated XGBoost model with cost-sensitive thresholding.
3. **Forecasting Engine** (`/forecasting`): Time-series forecasting of Expected Loss (PD × LGD × EAD) with rolling-origin cross-validation.
4. **Rust Inference Engine** (`/rust-engine`): High-performance scoring API built in Rust.

## Status
- [ ] Advanced SQL Feature Pipeline
- [ ] Credit Risk Model
- [ ] Forecasting Engine
- [ ] Rust Inference Engine
