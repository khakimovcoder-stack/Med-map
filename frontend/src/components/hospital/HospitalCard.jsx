import { Link } from 'react-router-dom';
import { Hospital, MapPin, Phone, ChevronRight } from 'lucide-react';
import { formatPhone } from '../../lib/format.js';

export default function HospitalCard({ hospital }) {
  const available = hospital.available_beds ?? 0;
  const total = hospital.total_beds ?? 0;
  const hasAvailability = available > 0;

  return (
    <Link
      to={`/hospitals/${hospital.id}`}
      className="group flex h-full flex-col gap-4 rounded border border-govgray-200 bg-white p-6 no-underline shadow-sm transition hover:border-gov-600 hover:shadow-md"
    >
      <div className="flex items-start justify-between gap-3 border-b border-govgray-100 pb-4">
        <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded bg-gov-600 text-white">
          <Hospital size={20} aria-hidden="true" />
        </div>
        {hospital.short_name && (
          <span className="rounded border border-govgray-200 bg-govgray-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-govgray-700">
            {hospital.short_name}
          </span>
        )}
      </div>

      <div className="flex-1 space-y-2">
        <h3 className="text-base font-semibold leading-snug text-govgray-900 transition-colors group-hover:text-gov-700">
          {hospital.name}
        </h3>
        <p className="flex items-start gap-1.5 text-sm text-govgray-500">
          <MapPin size={14} className="mt-0.5 shrink-0" aria-hidden="true" />
          <span>
            <span className="font-medium text-govgray-700">{hospital.city}</span>
            <span className="text-govgray-300"> &middot; </span>
            {hospital.address}
          </span>
        </p>
        {hospital.phone && (
          <p className="flex items-center gap-1.5 text-xs text-govgray-500">
            <Phone size={12} aria-hidden="true" />
            {formatPhone(hospital.phone)}
          </p>
        )}
      </div>

      <div className="border-t border-govgray-100 pt-4">
        <div className="flex items-end justify-between">
          <div>
            <div className="flex items-baseline gap-2">
              <span
                className={
                  hasAvailability
                    ? 'text-3xl font-bold text-success-700'
                    : 'text-3xl font-bold text-danger-500'
                }
              >
                {available}
              </span>
              <span className="text-sm font-medium text-govgray-500">ta bo&apos;sh joy</span>
            </div>
            <div className="mt-0.5 flex items-center gap-1.5 text-xs text-govgray-500">
              <span
                className={
                  hasAvailability
                    ? 'h-1.5 w-1.5 rounded-full bg-success-500 ring-2 ring-success-100'
                    : 'h-1.5 w-1.5 rounded-full bg-danger-500 ring-2 ring-danger-100'
                }
                aria-hidden="true"
              />
              {total > 0 ? `${total} karavotdan` : "Karavotlar haqida ma'lumot yo'q"}
            </div>
          </div>
          <span className="inline-flex items-center gap-1 rounded border border-gov-600 bg-white px-2 py-1 text-xs font-semibold text-gov-700 transition group-hover:bg-gov-600 group-hover:text-white">
            Tafsilot <ChevronRight size={14} aria-hidden="true" />
          </span>
        </div>
      </div>
    </Link>
  );
}
