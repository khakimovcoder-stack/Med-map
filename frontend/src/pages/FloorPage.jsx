import { useParams, Link } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import Container from '../components/layout/Container.jsx';
import Breadcrumb from '../components/layout/Breadcrumb.jsx';
import RoomCard from '../components/room/RoomCard.jsx';
import Skeleton from '../components/ui/Skeleton.jsx';
import EmptyState from '../components/ui/EmptyState.jsx';
import { useFloorRooms } from '../hooks/useFloorRooms.js';

function GridSkeleton() {
  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4 lg:grid-cols-5">
      {Array.from({ length: 10 }).map((_, idx) => (
        <Skeleton key={idx} className="aspect-square rounded-xl" />
      ))}
    </div>
  );
}

function StatusLegend() {
  const items = [
    { dot: 'bg-success-500 ring-success-100', label: "Bo'sh joy bor" },
    { dot: 'bg-danger-500 ring-danger-100', label: "To'liq band" },
    { dot: 'bg-unknown ring-gray-200', label: "Noma'lum" },
  ];
  return (
    <ul className="flex flex-wrap items-center gap-x-4 gap-y-2 text-xs text-gray-500">
      {items.map((item) => (
        <li key={item.label} className="flex items-center gap-1.5">
          <span className={`h-2 w-2 rounded-full ring-2 ${item.dot}`} aria-hidden="true" />
          {item.label}
        </li>
      ))}
    </ul>
  );
}

export default function FloorPage() {
  const { id } = useParams();
  const { data, isLoading, isError, refetch } = useFloorRooms(id);

  if (isLoading) {
    return (
      <Container className="py-8">
        <Skeleton className="mb-2 h-4 w-48" />
        <Skeleton className="mb-6 h-9 w-64" />
        <GridSkeleton />
      </Container>
    );
  }

  if (isError || !data) {
    return (
      <Container className="py-12">
        <EmptyState
          title="Qavat topilmadi"
          description="Bu qavat mavjud emas yoki vaqtinchalik ko'rsatib bo'lmaydi."
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

  const { floor, rooms } = data;
  const totalAvailable = rooms.reduce((acc, r) => acc + (r.available_beds || 0), 0);

  return (
    <Container className="py-6 sm:py-10">
      <Breadcrumb
        items={[
          { label: 'Bosh sahifa', to: '/' },
          {
            label: floor.hospital?.name || 'Shifoxona',
            to: floor.hospital?.id ? `/hospitals/${floor.hospital.id}` : undefined,
          },
          { label: `${floor.number}-qavat` },
        ]}
      />

      {/* Header */}
      <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            {floor.hospital?.name}
          </p>
          <h1 className="mt-1 text-3xl font-bold text-gray-900 sm:text-4xl">
            {floor.number}-qavat
          </h1>
          {floor.name && <p className="mt-0.5 text-sm text-gray-500">{floor.name}</p>}
        </div>
        <div className="rounded-xl border border-gray-100 bg-white px-4 py-3 shadow-card">
          <p className="text-xs font-medium uppercase tracking-wide text-gray-500">
            Bo'sh joylar
          </p>
          <p
            className={
              totalAvailable > 0
                ? 'text-2xl font-bold text-success-500'
                : 'text-2xl font-bold text-danger-500'
            }
          >
            {totalAvailable} ta
          </p>
        </div>
      </div>

      <div className="mb-4">
        <StatusLegend />
      </div>

      {/* Room grid */}
      {rooms.length === 0 ? (
        <EmptyState title="Palatalar topilmadi" />
      ) : (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4 lg:grid-cols-5">
          {rooms.map((room) => (
            <RoomCard key={room.id} room={room} />
          ))}
        </div>
      )}
    </Container>
  );
}
