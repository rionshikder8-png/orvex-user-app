/// Loading lifecycle of a dataset.
enum LoadStatus { idle, loading, ready, error, offline }

/// Where the data on screen came from. The UI uses this to label demo data.
enum DataSource { none, api, demo }
