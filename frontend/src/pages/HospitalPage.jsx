import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, MapPin, Phone, BedDouble, Activity } from 'lucide-react';
import Container from '../components/layout/Container.jsx';
import Breadcrumb from '../components/layout/Breadcrumb.jsx';
import FloorCard from '../components/floor/FloorCard.jsx';
import Skeleton from '../components/ui/Skeleton.jsx';
import EmptyState from '../components/ui/EmptyState.jsx';
import { useHospitalDetail } from '../hooks/useHospitalDetail.js';
import { formatPhone } from '../lib/format.js';

function HeroSkeleton() {
  return (
    <div className="mb-8 space-y-3">
      <Skeleton className="h-4 w-48" />
      <Skeleton className="h-10 w-3/4" />
      <Skeleton className="h-5 w-2/3" />
    </div>
  );
}

function FloorListSkeleton() {
  return (
    <div className="space-y-3">
      {Array.from({ length: 4 }).map((_, idx) => (
        <Skeleton key={idx} className="h-28 rounded-xl" />
      ))}
    </div>
  );
}

export default function HospitalPage() {
  const { id } = useParams();
  const { data, isLoading, isError, refetch } = useHospitalDetail(id);

  if (isLoading) {
    return (
      <Container className="py-8">
        <HeroSkeleton />
        <FloorListSkeleton />
      </Container>
    );
  }

  if (isError || !data) {
    return (
      <Container className="py-12">
        <EmptyState
          title="Shifoxona topilmadi"
          description="Bu shifoxona mavjud emas yoki vaqtinchalik mavjud emas."
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

  const total = data.total_beds ?? 0;
  const available = data.available_beds ?? 0;
  const occupancyPercent = total > 0 ? Math.round(((total - available) / total) * 100) : 0;

  return (
    <Container className="py-6 sm:py-10">
      <Breadcrumb
        items={[
          { label: 'Bosh sahifa', to: '/' },
          { label: data.short_name || data.name },
        ]}
      />

      {/* Hero */}
      <section className="mb-8 overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-card">
        <div className="relative bg-gradient-to-br from-brand-blue-800 to-brand-blue-500 px-6 py-8 text-white sm:px-8 sm:py-10">
          <div className="absolute right-0 top-0 h-32 w-32 -translate-y-12 translate-x-12 rounded-full bg-white/10 blur-3xl" aria-hidden="true" />
          {data.short_name && (
            <span className="inline-block rounded-full bg-white/15 px-3 py-1 text-xs font-semibold uppercase tracking-wider">
              {data.short_name}
            </span>
          )}
          <h1 className="mt-3 max-w-3xl text-2xl font-bold leading-snug sm:text-3xl lg:text-4xl">
            {data.name}
          </h1>
          <div className="mt-4 grid gap-2 text-sm text-white/90 sm:grid-cols-2">
            <p className="flex items-start gap-2">
              <MapPin size={16} className="mt-0.5 shrink-0" aria-hidden="true" />
              <span>{data.address}</span>
            </p>
            {data.phone && (
              <p className="flex items-center gap-2">
                <Phone size={16} className="shrink-0" aria-hidden="true" />
                <a href={`tel:${data.phone}`} className="hover:underline">
                  {formatPhone(data.phone)}
                </a>
              </p>
            )}
          </div>
        </div>

        <div className="grid grid-cols-3 divide-x divide-gray-100 bg-white text-center">
          <div className="px-4 py-5 sm:px-6">
            <p className="flex items-center justify-center gap-1.5 text-xs font-medium uppercase tracking-wide text-gray-500">
              <BedDouble size={12} aria-hidden="true" />
              Jami
            </p>
            <p className="mt-1 text-2xl font-bold text-gray-900 sm:text-3xl">{total}</p>
          </div>
          <div className="px-4 py-5 sm:px-6">
            <p className="flex items-center justify-center gap-1.5 text-xs font-medium uppercase tracking-wide text-gray-500">
              <Activity size={12} aria-hidden="true" />
              Bo'sh
            </p>
            <p className={available > 0 ? 'mt-1 text-2xl font-bold text-success-500 sm:text-3xl' : 'mt-1 text-2xl font-bold text-danger-500 sm:text-3xl'}>
              {available}
            </p>
          </div>
          <div className="px-4 py-5 sm:px-6">
            <p className="text-xs font-medium uppercase tracking-wide text-gray-500">
              Bandlik
            </p>
            <p className="mt-1 text-2xl font-bold text-gray-900 sm:text-3xl">{occupancyPercent}%</p>
          </div>
        </div>
      </section>

      {/* Floors */}
      <section>
        <div className="mb-4 flex items-baseline justify-between">
          <h2 className="text-xl font-semibold text-gray-900">Qavatlar</h2>
          <span className="text-sm text-gray-500">{data.floors?.length || 0} ta qavat</span>
        </div>

        <div className="space-y-3">
          {(data.floors || []).map((floor) => (
            <FloorCard key={floor.id} floor={floor} />
          ))}
        </div>
      </section>
    </Container>
  );
}
