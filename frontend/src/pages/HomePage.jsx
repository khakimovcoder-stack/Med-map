import { useMemo } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import {
  Search,
  ChevronRight,
  Bed,
  QrCode,
  ShieldCheck,
  Activity,
  Stethoscope,
  Briefcase,
  GraduationCap,
  HeartHandshake,
  Hospital,
  CheckCircle2,
  TrendingUp,
  BedDouble,
  MessageCircle,
} from 'lucide-react';
import HospitalCard from '../components/hospital/HospitalCard.jsx';
import Skeleton from '../components/ui/Skeleton.jsx';
import EmptyState from '../components/ui/EmptyState.jsx';
import { useHospitals } from '../hooks/useHospitals.js';

const QUICK_TILES = [
  { Icon: Bed, label: 'Bo\'sh joy qidirish', tone: 'bg-gradient-to-br from-sky-400 to-sky-600' },
  { Icon: ShieldCheck, label: 'OneID tasdiq', tone: 'bg-gradient-to-br from-blue-500 to-blue-700' },
  { Icon: QrCode, label: 'QR Skanerlash', tone: 'bg-gradient-to-br from-cyan-400 to-cyan-600' },
  { Icon: Activity, label: 'Real vaqtli holat', tone: 'bg-gradient-to-br from-teal-400 to-teal-600' },
  { Icon: Hospital, label: 'Shifoxonalar', tone: 'bg-gradient-to-br from-indigo-400 to-indigo-600' },
  { Icon: Stethoscope, label: 'Tibbiy yo\'nalish', tone: 'bg-gradient-to-br from-violet-400 to-violet-600' },
  { Icon: CheckCircle2, label: 'Bemor tasdig\'i', tone: 'bg-gradient-to-br from-emerald-400 to-emerald-600' },
  { Icon: TrendingUp, label: 'Statistika', tone: 'bg-gradient-to-br from-fuchsia-400 to-fuchsia-600' },
  { Icon: Briefcase, label: 'Tibbiy xodim', tone: 'bg-gradient-to-br from-rose-400 to-rose-600' },
  { Icon: HeartHandshake, label: 'Hamkorlik', tone: 'bg-gradient-to-br from-amber-400 to-amber-600' },
];

const SOHALAR = [
  {
    Icon: Stethoscope,
    title: "Sog'liqni saqlash",
    items: [
      "Vaqtincha mehnatga layoqatsizlik varaqasi",
      'Tibbiyot xodimlarining malaka toifasi',
    ],
    badge: 'bg-sky-100 text-sky-600',
  },
  {
    Icon: Briefcase,
    title: 'Bandlik va mehnat',
    items: [
      'Ishsizlik nafaqasi',
      'Ishga joylashishga kerakli hujjatlar',
    ],
    badge: 'bg-emerald-100 text-emerald-700',
  },
  {
    Icon: GraduationCap,
    title: "Ta'lim",
    items: [
      'Chet tilini bilish darajasini aniqlash',
      'Bakalavriat talabalari uchun davlat stipendiyalari',
    ],
    badge: 'bg-violet-100 text-violet-700',
  },
  {
    Icon: HeartHandshake,
    title: 'Ijtimoiy himoya',
    items: [
      "Bolalar nafaqasi va moddiy yordam olish",
      "Keksalar va nogironlar uchun sanatoriyga yo'llanma",
    ],
    badge: 'bg-rose-100 text-rose-700',
  },
];

function HeroBanner({ search, onSearchChange, hospitals }) {
  const totalAvailable = useMemo(
    () => hospitals?.reduce((acc, h) => acc + (h.available_beds || 0), 0) ?? 0,
    [hospitals],
  );
  const totalBeds = useMemo(
    () => hospitals?.reduce((acc, h) => acc + (h.total_beds || 0), 0) ?? 0,
    [hospitals],
  );

  return (
    <section className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#1856b2] via-[#2a8ed1] to-[#3ec5b1] px-6 py-7 text-white sm:px-8 sm:py-9">
      <div className="absolute inset-y-0 right-0 w-1/2 opacity-20" aria-hidden="true">
        <svg viewBox="0 0 200 200" className="h-full w-full">
          <circle cx="170" cy="50" r="80" fill="rgba(255,255,255,0.1)" />
          <circle cx="120" cy="180" r="60" fill="rgba(255,255,255,0.08)" />
        </svg>
      </div>
      <div className="relative flex flex-col items-stretch gap-5 sm:flex-row sm:items-center">
        <div className="min-w-0 flex-1">
          <h1 className="text-2xl font-bold tracking-tight sm:text-[28px]">
            Xush kelibsiz!
          </h1>
          <form
            role="search"
            onSubmit={(e) => e.preventDefault()}
            className="mt-4"
          >
            <label className="relative block">
              <Search
                size={18}
                className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[#1856b2]"
                aria-hidden="true"
              />
              <input
                type="search"
                value={search}
                onChange={(e) => onSearchChange(e.target.value)}
                placeholder="Qidiruv uchun matn kiriting, masalan — RIKM"
                className="h-12 w-full rounded-full bg-white pl-12 pr-4 text-sm text-govgray-900 placeholder:text-govgray-500 focus:outline-none focus:ring-2 focus:ring-white/60"
              />
            </label>
          </form>
        </div>

        {/* Live mini-stats (replaces gov.uz weather widget) */}
        <div className="flex shrink-0 items-center gap-3 self-start rounded-2xl bg-white/15 px-4 py-3 backdrop-blur-sm sm:self-auto">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-white/20 text-white">
            <BedDouble size={22} aria-hidden="true" />
          </div>
          <div className="flex flex-col leading-tight">
            <span className="rounded-full bg-white/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider">
              Toshkent · O&apos;zb
            </span>
            <span className="mt-1 text-2xl font-bold leading-none">
              {totalAvailable}{' '}
              <span className="text-base font-semibold text-white/85">
                / {totalBeds}
              </span>
            </span>
            <span className="text-[11px] text-white/85">hozir bo&apos;sh / jami</span>
          </div>
        </div>
      </div>
    </section>
  );
}

function QuickTilesRow() {
  return (
    <div className="-mx-2 mt-4 overflow-x-auto px-2 pb-2">
      <ul className="flex min-w-min items-stretch gap-3">
        {QUICK_TILES.map(({ Icon, label, tone }) => (
          <li key={label} className="w-[122px] shrink-0">
            <button
              type="button"
              className={`group relative flex h-[124px] w-full flex-col items-start justify-end overflow-hidden rounded-xl ${tone} p-3 text-left text-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md`}
            >
              <Icon
                size={48}
                className="absolute right-2 top-2 opacity-50 transition-opacity group-hover:opacity-90"
                strokeWidth={1.5}
              />
              <span className="relative text-[12px] font-semibold leading-tight">
                {label}
              </span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

function InfoBanners() {
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <div className="flex items-center gap-4 rounded-xl border border-sky-100 bg-sky-50/60 p-5">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white text-sky-600 ring-1 ring-sky-100">
          <Bed size={22} />
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-[14px] leading-tight">
            <span className="font-bold text-govgray-900">
              Sizning barcha tibbiy ma&apos;lumotlaringiz —
            </span>{' '}
            <span className="text-govgray-700">bir joyda!</span>
          </p>
        </div>
        <button
          type="button"
          className="shrink-0 rounded-full bg-[#1856b2] px-4 py-2 text-[12px] font-semibold text-white hover:bg-[#0f4690]"
        >
          Batafsil ma&apos;lumot
        </button>
      </div>
      <div className="flex items-center gap-4 rounded-xl border border-emerald-100 bg-emerald-50/60 p-5">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white text-emerald-600 ring-1 ring-emerald-100">
          <ShieldCheck size={22} />
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-[14px] leading-tight">
            <span className="font-bold text-govgray-900">
              Shaxsiy xabarnomalar —
            </span>{' '}
            <span className="text-govgray-700">muhim sana va eslatmalar!</span>
          </p>
        </div>
        <button
          type="button"
          className="shrink-0 rounded-full bg-[#1856b2] px-4 py-2 text-[12px] font-semibold text-white hover:bg-[#0f4690]"
        >
          Batafsil ma&apos;lumot
        </button>
      </div>
    </div>
  );
}

function SohalarBlock() {
  return (
    <section id="sohalar">
      <header className="mb-4 flex items-center justify-between">
        <h2 className="text-lg font-semibold text-[#1856b2]">Sohalar</h2>
        <a
          href="#barcha"
          className="inline-flex items-center gap-1 text-sm font-medium text-[#1856b2] hover:text-[#0f4690]"
        >
          Barcha xizmatlar <ChevronRight size={14} />
        </a>
      </header>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {SOHALAR.map(({ Icon, title, items, badge }) => (
          <article
            key={title}
            className="relative flex h-full flex-col overflow-hidden rounded-xl border border-govgray-200 bg-white p-5"
          >
            <h3 className="text-[15px] font-bold text-govgray-900">{title}</h3>
            <ul className="mt-4 flex-1 space-y-2 text-[13px] leading-snug">
              {items.map((it) => (
                <li
                  key={it}
                  className="flex items-start gap-1.5 text-[#1856b2] hover:text-[#0f4690]"
                >
                  <span className="mt-1 inline-block h-1 w-1 rounded-full bg-[#1856b2]" />
                  <a href="#x" className="hover:underline">
                    {it}
                  </a>
                </li>
              ))}
            </ul>
            <a
              href="#barchasi"
              className="mt-4 inline-flex items-center gap-1 text-[13px] font-medium text-[#1856b2] hover:text-[#0f4690]"
            >
              <ChevronRight size={13} />
              Barchasi
            </a>
            <span
              className={`absolute -bottom-2 right-2 flex h-14 w-14 items-center justify-center rounded-full opacity-80 ${badge}`}
              aria-hidden="true"
            >
              <Icon size={26} strokeWidth={1.6} />
            </span>
          </article>
        ))}
      </div>
    </section>
  );
}

export default function HomePage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const search = searchParams.get('q') || '';

  const handleSearchChange = (next) => {
    const params = new URLSearchParams(searchParams);
    if (next) params.set('q', next);
    else params.delete('q');
    setSearchParams(params, { replace: true });
  };

  const { data: hospitals, isLoading, isError, refetch } = useHospitals({ search });

  return (
    <div className="px-5 py-6 lg:px-8">
      <div className="space-y-6">
        <HeroBanner search={search} onSearchChange={handleSearchChange} hospitals={hospitals} />
        <QuickTilesRow />
        <InfoBanners />
        <SohalarBlock />

        {/* Hospitals — kept as a separate gov-card section */}
        <section id="hospitals">
          <header className="mb-4 flex items-end justify-between">
            <div>
              <h2 className="text-lg font-semibold text-[#1856b2]">
                {search ? 'Qidiruv natijalari' : 'Ulangan shifoxonalar'}
              </h2>
              {!search && hospitals && (
                <p className="text-[12px] text-govgray-500">
                  Hozirda {hospitals.length} ta tibbiy muassasa tizimga ulangan
                </p>
              )}
            </div>
            <Link
              to="/qr-simulator"
              className="inline-flex items-center gap-1 text-sm font-medium text-[#1856b2] hover:text-[#0f4690]"
            >
              QR Simulyator <ChevronRight size={14} />
            </Link>
          </header>

          {isLoading && (
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-56 rounded-xl" />
              ))}
            </div>
          )}

          {isError && (
            <EmptyState
              icon={Hospital}
              title="Ma'lumotni olishda xatolik"
              description="Server bilan bog'lanib bo'lmadi."
              action={
                <button
                  onClick={() => refetch()}
                  className="rounded-lg bg-[#1856b2] px-4 py-2 text-sm font-semibold text-white hover:bg-[#0f4690]"
                >
                  Qaytadan urinish
                </button>
              }
            />
          )}

          {!isLoading && !isError && hospitals?.length === 0 && (
            <EmptyState
              icon={Hospital}
              title="Hech narsa topilmadi"
              description={
                search
                  ? `"${search}" bo'yicha shifoxona topilmadi.`
                  : "Ro'yxat bo'sh."
              }
            />
          )}

          {!isLoading && !isError && hospitals?.length > 0 && (
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {hospitals.map((h) => (
                <HospitalCard key={h.id} hospital={h} />
              ))}
            </div>
          )}
        </section>
      </div>

      {/* Floating chat-like hint badge — like gov.uz */}
      <button
        type="button"
        className="fixed bottom-6 right-6 hidden h-12 w-12 items-center justify-center rounded-full bg-[#1856b2] text-white shadow-lg ring-4 ring-[#1856b2]/15 hover:bg-[#0f4690] lg:flex"
        aria-label="Yordam"
      >
        <MessageCircle size={20} aria-hidden="true" />
      </button>
    </div>
  );
}
