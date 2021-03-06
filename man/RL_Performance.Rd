% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EconometricsFunctions.R
\name{RL_Performance}
\alias{RL_Performance}
\title{ARIMA_Performance creates and stores model results in Experiment Grid}
\usage{
RL_Performance(
  Results = Results,
  NextGrid = NextGrid,
  TrainValidateShare = c(0.5, 0.5),
  MaxFourierTerms = NULL,
  XREGFC = XREGFC,
  ExperimentGrid = ExperimentGrid,
  run = run,
  train = train,
  ValidationData = ValidationData,
  HoldOutPeriods = HoldOutPeriods,
  FinalScore = FALSE
)
}
\arguments{
\item{Results}{This is a time series model}

\item{NextGrid}{Bandit grid}

\item{TrainValidateShare}{The values used to blend training and validation performance}

\item{MaxFourierTerms}{Numeric value}

\item{XREGFC}{Fourier terms for forecasting}

\item{ExperimentGrid}{The results collection table}

\item{run}{Iterator}

\item{train}{Data set}

\item{ValidationData}{Data set}

\item{HoldOutPeriods}{Passthrough}

\item{FinalScore}{FALSE}
}
\description{
ARIMA_Performance creates and stores model results in Experiment Grid
}
\seealso{
Other Time Series Helper: 
\code{\link{FinalBuildArfima}()},
\code{\link{FinalBuildArima}()},
\code{\link{FinalBuildETS}()},
\code{\link{FinalBuildNNET}()},
\code{\link{FinalBuildTBATS}()},
\code{\link{FinalBuildTSLM}()},
\code{\link{GenerateParameterGrids}()},
\code{\link{OptimizeArfima}()},
\code{\link{OptimizeArima}()},
\code{\link{OptimizeETS}()},
\code{\link{OptimizeNNET}()},
\code{\link{OptimizeTBATS}()},
\code{\link{OptimizeTSLM}()},
\code{\link{ParallelAutoARIMA}()},
\code{\link{ParallelAutoArfima}()},
\code{\link{ParallelAutoETS}()},
\code{\link{ParallelAutoNNET}()},
\code{\link{ParallelAutoTBATS}()},
\code{\link{ParallelAutoTSLM}()},
\code{\link{PredictArima}()},
\code{\link{Regular_Performance}()},
\code{\link{StackedTimeSeriesEnsembleForecast}()},
\code{\link{TimeSeriesDataPrepare}()},
\code{\link{WideTimeSeriesEnsembleForecast}()}
}
\author{
Adrian Antico
}
\concept{Time Series Helper}
