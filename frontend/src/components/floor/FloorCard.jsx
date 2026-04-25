import { Link } from 'react-router-dom';
import { Building2, ChevronRight, BedDouble } from 'lucide-react';
import Card from '../ui/Card.jsx';
import ProgressBar from '../ui/ProgressBar.jsx';

export default function FloorCard({ floor }) {
  const available = floor.available_beds ?? 0;
  const total = floor.total_beds ?? 0;
  const hasAvailability = available > 0;
  const tone = hasAvailability ? 'green' : total > 0 ? 'red' : 'gray';

  return (
    <Card
      as={Link}
      to={`/floors/${floor.id}`}
      interactive
      className="group flex flex-col gap-4 sm:flex-row sm:items-center"
    >
      <div className="flex shrink-0 items-center gap-4">
        <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-brand-blue-50 text-brand-blue-800 ring-1 ring-brand-blue-100">
          <Building2 size={24} aria-hidden="true" />
        </div>
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            Qavat
          </p>
          <h3 className="text-2xl font-bold leading-tight text-gray-900">
            {floor.number}-qavat
          </h3>
          {floor.name && <p className="text-xs text-gray-500">{floor.name}</p>}
        </div>
      </div>

      <div className="flex-1 sm:px-4">
        <div className="mb-2 flex items-center justify-between text-sm">
          <span className="flex items-center gap-1.5 font-semibold text-gray-900">
            <BedDouble size={14} className="text-gray-500" aria-hidden="true" />
            <span
              className={
                hasAvailability ? 'text-success-500' : total > 0 ? 'text-danger-500' : 'text-gray-500'
              }
            >
              {available}
            </span>
            <span className="font-normal text-gray-500"> / {total} bo'sh</span>
          </span>
          {floor.rooms_count != null && (
            <span className="text-xs text-gray-500">{floor.rooms_count} palata</span>
          )}
        </div>
        <ProgressBar value={available} total={total} tone={tone} />
      </div>

      <ChevronRight
        size={20}
        className="hidden shrink-0 text-gray-400 transition-transform group-hover:translate-x-0.5 group-hover:text-brand-blue-800 sm:block"
        aria-hidden="true"
      />
    </Card>
  );
}
