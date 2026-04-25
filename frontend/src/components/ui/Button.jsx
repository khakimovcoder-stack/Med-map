import clsx from 'clsx';

const VARIANTS = {
  primary:
    'bg-brand-blue-800 text-white hover:bg-brand-blue-900 active:scale-[0.98] shadow-sm',
  success: 'bg-success-500 text-white hover:bg-emerald-600 active:scale-[0.98] shadow-sm',
  danger: 'bg-danger-500 text-white hover:bg-red-600 active:scale-[0.98] shadow-sm',
  secondary:
    'bg-white text-gray-900 border border-gray-200 hover:border-brand-blue-100 hover:text-brand-blue-800',
  ghost: 'bg-transparent text-gray-700 hover:bg-gray-100',
};

const SIZES = {
  sm: 'h-9 px-3 text-sm',
  md: 'h-11 px-5 text-base',
  lg: 'h-12 px-6 text-base',
};

export default function Button({
  variant = 'primary',
  size = 'md',
  className,
  type = 'button',
  disabled,
  children,
  ...rest
}) {
  return (
    <button
      type={type}
      disabled={disabled}
      className={clsx(
        'inline-flex items-center justify-center gap-2 rounded-md font-semibold transition-all duration-150 ease-out-expo disabled:cursor-not-allowed disabled:opacity-50',
        VARIANTS[variant],
        SIZES[size],
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  );
}
