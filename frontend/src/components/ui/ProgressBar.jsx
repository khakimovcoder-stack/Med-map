import clsx from 'clsx';

export default function ProgressBar({ value = 0, total = 1, tone = 'green', className }) {
  const safeTotal = total > 0 ? total : 1;
  const ratio = Math.min(1, Math.max(0, value / safeTotal));
  const percent = Math.round(ratio * 100);

  const fillTone =
    tone === 'green'
      ? 'bg-success-500'
      : tone === 'red'
        ? 'bg-danger-500'
        : tone === 'blue'
          ? 'bg-brand-blue-800'
          : 'bg-gray-400';

  return (
    <div className={clsx('h-2 w-full rounded-full bg-gray-100 overflow-hidden', className)}>
      <div
        className={clsx('h-full rounded-full transition-[width] duration-500 ease-out-expo', fillTone)}
        style={{ width: `${percent}%` }}
        aria-valuenow={percent}
        aria-valuemin={0}
        aria-valuemax={100}
        role="progressbar"
      />
    </div>
  );
}
