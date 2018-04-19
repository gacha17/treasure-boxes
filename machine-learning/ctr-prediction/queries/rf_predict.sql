WITH ensembled AS (
  SELECT
    rowid,
    rf_ensemble(pred.value, pred.posteriori, model_weight) AS pred
  FROM (
    SELECT
      t.rowid,
      p.model_weight,
      tree_predict(p.model_id, p.model, feature_hashing(t.features), '-classification') AS pred
    FROM
      rf_model p
    LEFT OUTER JOIN
      test t
  ) t1
  GROUP BY
    rowid
)
-- DIGDAG_INSERT_LINE
SELECT
  rowid,
  -- use calibrated CTR to prevent negative effect of over-sampling
  pred.probabilities[1] / (pred.probabilities[1] + pred.probabilities[0] / ${td.last_results.downsampling_rate}) AS predicted_ctr
FROM
  ensembled
;