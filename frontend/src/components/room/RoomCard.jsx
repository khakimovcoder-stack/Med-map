import { Link } from 'react-router-dom';
import { CheckCircle2, XCircle, HelpCircle, Clock } from 'lucide-react';
import clsx from 'clsx';
import { formatRelativeMinutes } from '../../lib/format.js';

const STATUS_STYLES = {
  green: {
    border: 'border-success-500',
    glow: 'before:bg-success-100/60',
    dot: 'bg-success-500 ring-success-100',
    text: 'text-emerald-700',
    icon: CheckCircle2,
  },
  red: {
    border: 'border-danger-500',
    glow: 'before:bg-danger-100/60',
    dot: 'bg-danger-500 ring-danger-100',
    text: 'text-red-700',
    icon: XCircle,
  },
  gray: {
    border: 'border-gray-300',
    glow: 'before:bg-gray-100/60',
    dot: 'bg-unknown ring-gray-200',
    text: 'text-gray-600',
    icon: HelpCircle,
  },
};

export default function RoomCard({ room }) {
  const style = STATUS_STYLES[room.status_color] || STATUS_STYLES.gray;
  const Icon = style.icon;

  return (
    <Link
      to={`/rooms/${room.id}`}
      aria-label={`${room.number}-palata, ${room.status_label}`}
      className={clsx(
        'group relative flex aspect-square flex-col justify-between rounded-xl border-2 bg-white p-4 shadow-card transition-all duration-150 ease-out-expo overflow-hidden',
        'before:absolute before:-right-6 before:-top-6 before:h-16 before:w-16 before:rounded-full before:blur-xl',
        style.border,
        style.glow,
        'hover:-translate-y-0.5 hover:shadow-card-hover',
      )}
    >
      <div className="relative flex items-start justify-between">
        <span className="text-2xl font-bold leading-none tracking-tight text-gray-900">
          {room.number}
        </span>
        <span
          className={clsx('h-2.5 w-2.5 rounded-full ring-4', style.dot)}
          aria-hidden="true"
        />
      </div>

      <div className="relative space-y-1">
        <div className={clsx('flex items-center gap-1 text-sm font-semibold', style.text)}>
          <Icon size={14} aria-hidden="true" />
          <span>{room.status_label}</span>
        </div>
        {room.minutes_since_update != null && (
          <p className="flex items-center gap-1 text-[11px] text-gray-500">
            <Clock size={10} aria-hidden="true" />
            {formatRelativeMinutes(room.minutes_since_update)}
          </p>
        )}
      </div>
    </Link>
  );
}
