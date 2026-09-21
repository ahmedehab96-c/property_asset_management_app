import FormField from './FormField';

export default function ResourceForm({ fields, values, onChange, relationOptions }) {
  return (
    <div className="form-grid">
      {fields.map((field) => (
        <FormField
          key={field.name}
          field={field}
          value={values[field.name]}
          onChange={onChange}
          options={field.type === 'relation-select' ? relationOptions[field.name] : undefined}
        />
      ))}
    </div>
  );
}
