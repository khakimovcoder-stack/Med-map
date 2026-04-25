import clsx from 'clsx';

const TONES = {
  blue: 'bg-brand-blue-50 text-brand-blue-800 border-brand-blue-100',
  green: 'bg-success-100 text-emerald-700 border-emerald-200',
  red: 'bg-danger-100 text-red-700 border-red-200',
  gray: 'bg-gray-100 text-gray-600 border-gray-200',
  amber: 'bg-amber-50 text-amber-700 border-amber-200',
};

export default function Badge({ tone = 'gray', className, children, icon: Icon, ...rest }) {
  return (
    <span
      className={clsx(
        'inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-semibold',
        TONES[tone],
        className,
      )}
      {...rest}
    >
      {Icon && <Icon size={14} aria-hidden="true" />}
      {children}
    </span>
  );
}
