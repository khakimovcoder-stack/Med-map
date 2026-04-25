import clsx from 'clsx';

export default function Card({
  as: As = 'div',
  className,
  interactive = false,
  children,
  ...rest
}) {
  return (
    <As
      className={clsx(
        'rounded-xl border border-gray-100 bg-white p-5 shadow-card',
        interactive &&
          'transition-all duration-150 ease-out-expo hover:-translate-y-0.5 hover:border-brand-blue-100 hover:shadow-card-hover cursor-pointer',
        className,
      )}
      {...rest}
    >
      {children}
    </As>
  );
}
