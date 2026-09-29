import "./CaptionGroupingControl.css";

export function CaptionGroupingControl({ value, onChange, disabled, t }) {
  return (
    <label className="caption-grouping-control">
      <span>{t("captionGrouping")}</span>
      <select aria-label={t("captionGrouping")} value={value} onChange={(event) => onChange(event.target.value)} disabled={disabled}>
        <option value="phrases">{t("captionGroupingPhrases")}</option>
        <option value="words">{t("captionGroupingWords")}</option>
      </select>
    </label>
  );
}
