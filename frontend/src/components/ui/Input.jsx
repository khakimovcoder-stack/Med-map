import clsx from 'clsx';
import { forwardRef } from 'react';

const Input = forwardRef(function Input(
  { className, leftIcon: LeftIcon, rightSlot, ...rest },
  ref,
) {
  return (
    <div className="relative w-full">
      {LeftIcon && (
        <span className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">
          <LeftIcon size={20} aria-hidden="true" />
        </span>
      )}
      <input
        ref={ref}
        className={clsx(
          'h-11 w-full rounded-md border border-gray-200 bg-white text-base text-gray-900 placeholder:text-gray-400 transition-all duration-150 ease-out-expo focus:border-brand-blue-800 focus:ring-2 focus:ring-brand-blue-800/20 focus:outline-none',
          LeftIcon ? 'pl-12' : 'pl-4',
          rightSlot ? 'pr-12' : 'pr-4',
          className,
        )}
        {...rest}
      />
      {rightSlot && (
        <span className="absolute right-3 top-1/2 -translate-y-1/2">{rightSlot}</span>
      )}
    </div>
  );
});

export default Input;
