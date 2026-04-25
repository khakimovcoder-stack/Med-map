import clsx from 'clsx';
import { Bed, CheckCircle2, XCircle, HelpCircle, Star } from 'lucide-react';

const STATUS_CONFIG = {
  BAND: {
    label: 'Band',
    bg: 'bg-danger-100',
    border: 'border-danger-500',
    text: 'text-red-700',
    iconBg: 'bg-danger-500',
    Icon: XCircle,
  },
  BOSH: {
    label: "Bo'sh",
    bg: 'bg-success-100',
    border: 'border-success-500',
    text: 'text-emerald-700',
    iconBg: 'bg-success-500',
    Icon: CheckCircle2,
  },
  NOMALUM: {
    label: "Noma'lum",
    bg: 'bg-gray-100',
    border: 'border-gray-300',
    text: 'text-gray-600',
    iconBg: 'bg-unknown',
    Icon: HelpCircle,
  },
};

export default function BedTile({ bed }) {
  const config = STATUS_CONFIG[bed.current_status] || STATUS_CONFIG.NOMALUM;
  const Icon = config.Icon;

  return (
    <div
      className={clsx(
        'relative flex h-full min-h-[112px] flex-col justify-between rounded-lg border-2 p-3 shadow-card transition-all duration-150 ease-out-expo',
        config.bg,
        config.border,
      )}
      role="group"
      aria-label={`Karavot ${bed.position}, ${config.label}`}
    >
      {/* Position number */}
      <div className="flex items-start justify-between">
        <span className="flex h-6 w-6 items-center justify-center rounded-md bg-white/80 text-xs font-bold text-gray-700 shadow-sm">
          {bed.position}
        </span>
        {bed.is_near_window && (
          <span
            className="flex items-center gap-0.5 rounded-full bg-white/90 px-1.5 py-0.5 text-[10px] font-semibold text-amber-600 shadow-sm"
            aria-label="Deraza yonida"
          >
            <Star size={10} fill="currentColor" aria-hidden="true" />
            deraza
          </span>
        )}
      </div>

      {/* Bed icon center */}
      <div className="flex items-center justify-center py-1">
        <div
          className={clsx(
            'flex h-10 w-10 items-center justify-center rounded-full text-white shadow-sm',
            config.iconBg,
          )}
        >
          <Bed size={18} aria-hidden="true" />
        </div>
      </div>

      {/* Status label */}
      <div className={clsx('flex items-center justify-center gap-1 text-xs font-semibold', config.text)}>
        <Icon size={12} aria-hidden="true" />
        <span>{config.label}</span>
      </div>
    </div>
  );
}
