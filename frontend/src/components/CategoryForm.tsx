import React, { useState } from "react";
import { TextField, Button } from "../vibes";
import { COLORS } from "../constants/colors";

interface CategoryFormProps {
  onSubmit: (name: string) => Promise<void>;
  onCancel?: () => void;
  submitLabel?: string;
}

export function CategoryForm({
  onSubmit,
  onCancel,
  submitLabel = "Add Category",
}: CategoryFormProps) {
  const [name, setName] = useState("");
  const [validationError, setValidationError] = useState<string | undefined>();

  const [submissionError, setSubmissionError] = useState<string | undefined>();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const formStyle: React.CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "1rem",
  };

  const buttonGroupStyle: React.CSSProperties = {
    display: "flex",
    gap: "0.5rem",
    marginTop: "0.5rem",
  };

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const nameTrimmed = name.trim();
    if (!nameTrimmed) {
      setValidationError("Name is required");
      return;
    }
    setValidationError(undefined);
    setSubmissionError(undefined);
    setIsSubmitting(true);
    try {
      await onSubmit(nameTrimmed);
    } catch (err) {
      setSubmissionError(err instanceof Error ? err.message : "Error creating category. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} style={formStyle}>
      <TextField
        label="Category Name"
        type="text"
        placeholder="Enter category name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        error={validationError}
        fullWidth
        required
      />

      <p style={{ color: COLORS.danger, fontSize: "0.875rem", margin: 0, minHeight: "1.25rem" }}>
        {submissionError}
      </p>

      <div style={buttonGroupStyle}>
        <Button
          type="submit"
          variant="primary"
          disabled={isSubmitting}
          fullWidth
        >
          {isSubmitting ? "Submitting..." : submitLabel}
        </Button>
        {onCancel && (
          <Button
            type="button"
            variant="secondary"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
