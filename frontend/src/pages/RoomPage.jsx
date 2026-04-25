import { useParams, Link } from 'react-router-dom';
import {
  ArrowLeft,
  Clock,
  Users,
  ShieldCheck,
  Star,
  Bed as BedIcon,
  CheckCircle2,
  XCircle,
  HelpCircle,
} from 'lucide-react';
import Container from '../components/layout/Container.jsx';
import Breadcrumb from '../components/layout/Breadcrumb.jsx';
import RoomVisual2D from '../components/room/RoomVisual2D.jsx';
import ProgressBar from '../components/ui/ProgressBar.jsx';
import Skeleton from '../components/ui/Skeleton.jsx';
import EmptyState from '../components/ui/EmptyState.jsx';
import { useRoom } from '../hooks/useRoom.js';
import { formatRelativeMinutes, minutesSince } from '../lib/format.js';

const STATUS_META = {
  BAND: { label: 'Band', tone: 'text-red-700', dot: 'bg-danger-500', Icon: XCircle },
  BOSH: { label: "Bo'sh", tone: 'text-emerald-700', dot: 'bg-success-500', Icon: CheckCircle2 },
  NOMALUM: { label: "Noma'lum", tone: 'text-gray-600', dot: 'bg-unknown', Icon: HelpCircle },
};

function BedRow({ bed }) {
  const meta = STATUS_META[bed.current_status] || STATUS_META.NOMALUM;
  const Icon = meta.Icon;
  const lastMinutes = minutesSince(bed.last_confirmed_at);

  return (
    <li className="flex items-center justify-between gap-3 rounded-lg border border-gray-100 bg-white px-3 py-2.5">
      <div className="flex items-center gap-3">
        <span className="flex h-8 w-8 items-center justify-center rounded-md bg-gray-50 text-sm font-bold text-gray-700">
          {bed.position}
        </span>
        <div className="min-w-0">
          <div className="flex items-center gap-2 text-sm font-semibold text-gray-900">
            <BedIcon size={14} className="text-gray-500" aria-hidden="true" />
            <span>Karavot {bed.position}</span>
            {bed.is_near_window && (
              <span className="inline-flex items-center gap-0.5 rounded-full bg-amber-50 px-1.5 py-0.5 text-[10px] font-semibold text-amber-700">
                <Star size={10} fill="currentColor" aria-hidden="true" /> deraza
              </span>
            )}
          </div>
          <p className="truncate text-xs text-gray-500">
            {lastMinutes != null ? formatRelativeMinutes(lastMinutes) : 'Hali tasdiqlanmagan'}
            {bed.confirmation_count > 0 && (
              <span> &middot; {bed.confirmation_count} tasdiq</span>
            )}
          </p>
        </div>
      </div>
      <span className={`flex items-center gap-1.5 text-sm font-semibold ${meta.tone}`}>
        <Icon size={14} aria-hidden="true" />
        {meta.label}
      </span>
    </li>
  );
}

function RoomLoading() {
  return (
    <Container className="py-8">
      <Skeleton className="mb-2 h-4 w-72" />
      <Skeleton className="mb-6 h-9 w-48" />
      <div className="grid gap-6 lg:grid-cols-[1.1fr_1fr]">
        <Skeleton className="h-[480px] rounded-2xl" />
        <Skeleton className="h-[480px] rounded-2xl" />
      </div>
    </Container>
  );
}

export default function RoomPage() {
  const { id } = useParams();
  const { data: room, isLoading, isError, isFetching, refetch } = useRoom(id);

  if (isLoading) return <RoomLoading />;

  if (isError || !room) {
    return (
      <Container className="py-12">
        <EmptyState
          title="Palata topilmadi"
          description="Bu palata mavjud emas yoki vaqtinchalik ko'rsatib bo'lmaydi."
          action={
            <Link
              to="/"
              className="inline-flex items-center gap-1.5 rounded-md bg-brand-blue-800 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-blue-900"
            >
              <ArrowLeft size={14} />
              Bosh sahifaga qaytish
            </Link>
          }
        />
        <div className="mt-4 text-center">
          <button
            type="button"
            onClick={() => refetch()}
            className="text-sm font-medium text-brand-blue-800 hover:underline"
          >
            Qaytadan urinish
          </button>
        </div>
      </Container>
    );
  }

  const total = room.total_beds ?? room.beds?.length ?? 0;
  const available = room.available_beds ?? 0;
  const summary = room.confirmation_summary || {};
  const minutesAgo = summary.minutes_since_update ?? minutesSince(summary.last_updated_at);

  return (
    <Container className="py-6 sm:py-10">
      <Breadcrumb
        items={[
          { label: 'Bosh sahifa', to: '/' },
          {
            label: room.hospital?.short_name || room.hospital?.name || 'Shifoxona',
            to: room.hospital?.id ? `/hospitals/${room.hospital.id}` : undefined,
          },
          {
            label: `${room.floor?.number}-qavat`,
            to: room.floor?.id ? `/floors/${room.floor.id}` : undefined,
          },
          { label: `${room.number}-palata` },
        ]}
      />

      <div className="mb-6 flex items-center justify-between gap-3">
        <Link
          to={room.floor?.id ? `/floors/${room.floor.id}` : '/'}
          className="inline-flex items-center gap-1.5 text-sm font-medium text-gray-600 transition-colors hover:text-brand-blue-800"
        >
          <ArrowLeft size={16} aria-hidden="true" />
          Qaytish
        </Link>
        {isFetching && (
          <span className="inline-flex items-center gap-1.5 text-xs font-medium text-brand-blue-800">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-brand-blue-500 opacity-75" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-brand-blue-500" />
            </span>
            Yangilanmoqda...
          </span>
        )}
      </div>

      <div className="grid gap-6 lg:grid-cols-[1.1fr_1fr] lg:gap-8">
        {/* LEFT: 2D Visual */}
        <div>
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-sm font-semibold uppercase tracking-wider text-gray-500">
              Xona ko'rinishi (yuqoridan)
            </h2>
          </div>
          <RoomVisual2D beds={room.beds} />
          <p className="mt-3 text-xs text-gray-500">
            Yulduzcha (<Star size={11} className="-mt-0.5 inline-block text-amber-500" fill="currentColor" aria-hidden="true" />) deraza yonidagi karavotni bildiradi.
          </p>
        </div>

        {/* RIGHT: Info Panel */}
        <div className="space-y-5">
          <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-card">
            <div className="border-b border-gray-100 bg-gradient-to-br from-brand-blue-50 to-white px-6 py-5">
              <p className="text-xs font-semibold uppercase tracking-wider text-brand-blue-800">
                Palata
              </p>
              <h1 className="mt-1 text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                {room.number}
              </h1>
              <p className="mt-1 text-sm text-gray-600">
                {room.hospital?.name} &middot; {room.floor?.number}-qavat
              </p>
            </div>

            <div className="space-y-4 px-6 py-5">
              {/* Availability */}
              <div>
                <div className="flex items-baseline justify-between">
                  <span className="text-sm font-medium text-gray-500">Bo'sh joylar</span>
                  <span className="text-sm">
                    <span
                      className={
                        available > 0
                          ? 'text-2xl font-bold text-success-500'
                          : 'text-2xl font-bold text-danger-500'
                      }
                    >
                      {available}
                    </span>
                    <span className="ml-1 font-medium text-gray-500">/ {total}</span>
                  </span>
                </div>
                <ProgressBar
                  className="mt-2"
                  value={available}
                  total={total}
                  tone={available > 0 ? 'green' : 'red'}
                />
              </div>

              {/* Last updated */}
              <div className="flex items-center gap-3 rounded-lg bg-gray-50 px-3 py-2.5">
                <span className="flex h-9 w-9 items-center justify-center rounded-full bg-white text-brand-blue-800 shadow-sm">
                  <Clock size={16} aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <p className="text-xs font-medium uppercase tracking-wide text-gray-500">
                    Oxirgi yangilanish
                  </p>
                  <p className="text-sm font-semibold text-gray-900">
                    {formatRelativeMinutes(minutesAgo)}
                  </p>
                </div>
              </div>

              {/* Confirmations */}
              <div className="grid grid-cols-2 gap-3">
                <div className="rounded-lg border border-gray-100 bg-white px-3 py-2.5">
                  <p className="flex items-center gap-1 text-[11px] font-medium uppercase tracking-wide text-gray-500">
                    <Users size={11} aria-hidden="true" /> Bemorlar
                  </p>
                  <p className="mt-0.5 text-xl font-bold text-gray-900">
                    {summary.unique_users_24h ?? 0}
                  </p>
                  <p className="text-[11px] text-gray-500">tasdiqlagan (24s)</p>
                </div>
                <div className="rounded-lg border border-gray-100 bg-white px-3 py-2.5">
                  <p className="flex items-center gap-1 text-[11px] font-medium uppercase tracking-wide text-gray-500">
                    <ShieldCheck size={11} aria-hidden="true" /> Tasdiqlar
                  </p>
                  <p className="mt-0.5 text-xl font-bold text-gray-900">
                    {summary.total_confirmations_24h ?? 0}
                  </p>
                  <p className="text-[11px] text-gray-500">jami (24s)</p>
                </div>
              </div>
            </div>
          </div>

          {/* Beds list */}
          <div className="rounded-2xl border border-gray-100 bg-white p-5 shadow-card">
            <h3 className="mb-3 text-sm font-semibold uppercase tracking-wider text-gray-500">
              Karavotlar
            </h3>
            <ul className="space-y-2">
              {[...(room.beds || [])]
                .sort((a, b) => a.position - b.position)
                .map((bed) => (
                  <BedRow key={bed.id || bed.position} bed={bed} />
                ))}
            </ul>
          </div>

          {/* Anti-cheat / source notice */}
          <div className="flex items-start gap-3 rounded-xl border border-brand-blue-100 bg-brand-blue-50 px-4 py-3 text-sm text-brand-blue-800">
            <ShieldCheck size={18} className="mt-0.5 shrink-0" aria-hidden="true" />
            <p>
              Ushbu ma'lumot xonadagi bemorlar tomonidan{' '}
              <span className="font-semibold">OneID orqali tasdiqlangan</span>. Yolg'on
              ma'lumot kiritish qonuniy javobgarlikka sabab bo'ladi.
            </p>
          </div>
        </div>
      </div>
    </Container>
  );
}
