import { useMemo, useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { Building2, Printer, QrCode, ScanLine } from 'lucide-react';
import Container from '../components/layout/Container.jsx';
import Card from '../components/ui/Card.jsx';
import Skeleton from '../components/ui/Skeleton.jsx';
import EmptyState from '../components/ui/EmptyState.jsx';
import { useHospitals } from '../hooks/useHospitals.js';
import { useQrCodes } from '../hooks/useQrCodes.js';

export default function QrSimulationPage() {
  const [hospitalId, setHospitalId] = useState('');
  const [floorFilter, setFloorFilter] = useState('all');
  const hospitalsQuery = useHospitals();
  const qrQuery = useQrCodes(hospitalId || undefined);

  const hospitals = hospitalsQuery.data ?? [];
  const allQrs = qrQuery.data ?? [];

  const floors = useMemo(() => {
    const set = new Set(allQrs.map((q) => q.floor_number));
    return [...set].sort((a, b) => a - b);
  }, [allQrs]);

  const visibleQrs = useMemo(() => {
    if (floorFilter === 'all') return allQrs;
    return allQrs.filter((q) => String(q.floor_number) === floorFilter);
  }, [allQrs, floorFilter]);

  const grouped = useMemo(() => {
    const map = new Map();
    visibleQrs.forEach((q) => {
      const key = `${q.hospital_short_name} / ${q.floor_number}-qavat`;
      if (!map.has(key)) map.set(key, []);
      map.get(key).push(q);
    });
    return [...map.entries()];
  }, [visibleQrs]);

  return (
    <Container className="py-8 print:py-0">
      <div className="mb-6 flex flex-col gap-4 print:hidden">
        <div className="flex items-center gap-3">
          <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-brand-blue-50 text-brand-blue-800">
            <QrCode size={22} strokeWidth={2.25} />
          </span>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">QR Simulyator</h1>
            <p className="text-sm text-gray-500">
              Demo uchun: ekrandan QR kodni telefon bilan skaner qiling yoki chop eting.
            </p>
          </div>
        </div>

        <Card className="flex flex-wrap items-end gap-4 p-4">
          <label className="flex flex-col text-xs font-medium text-gray-600">
            Shifoxona
            <select
              value={hospitalId}
              onChange={(e) => {
                setHospitalId(e.target.value);
                setFloorFilter('all');
              }}
              className="mt-1 h-10 rounded-md border border-gray-200 bg-white px-3 text-sm text-gray-900 focus:border-brand-blue-800 focus:outline-none focus:ring-2 focus:ring-brand-blue-100"
            >
              <option value="">Hammasi</option>
              {hospitals.map((h) => (
                <option key={h.id} value={h.id}>
                  {h.short_name || h.name}
                </option>
              ))}
            </select>
          </label>

          <label className="flex flex-col text-xs font-medium text-gray-600">
            Qavat
            <select
              value={floorFilter}
              onChange={(e) => setFloorFilter(e.target.value)}
              className="mt-1 h-10 rounded-md border border-gray-200 bg-white px-3 text-sm text-gray-900 focus:border-brand-blue-800 focus:outline-none focus:ring-2 focus:ring-brand-blue-100"
            >
              <option value="all">Hamma qavatlar</option>
              {floors.map((f) => (
                <option key={f} value={String(f)}>
                  {f}-qavat
                </option>
              ))}
            </select>
          </label>

          <div className="ml-auto flex items-center gap-3 text-xs text-gray-500">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-brand-blue-50 px-2.5 py-1 font-semibold text-brand-blue-800">
              <ScanLine size={14} /> {visibleQrs.length} ta QR
            </span>
            <button
              type="button"
              onClick={() => window.print()}
              className="inline-flex items-center gap-1.5 rounded-md border border-gray-200 bg-white px-3 py-1.5 text-xs font-semibold text-gray-700 hover:border-brand-blue-200 hover:text-brand-blue-800"
            >
              <Printer size={14} /> Chop etish
            </button>
          </div>
        </Card>
      </div>

      {qrQuery.isLoading ? (
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
          {Array.from({ length: 10 }).map((_, i) => (
            <Skeleton key={i} className="aspect-square" />
          ))}
        </div>
      ) : visibleQrs.length === 0 ? (
        <EmptyState
          title="QR kodlar topilmadi"
          description="Yana boshqa shifoxona yoki qavat tanlang."
        />
      ) : (
        <div className="space-y-10">
          {grouped.map(([groupTitle, items]) => (
            <section key={groupTitle}>
              <header className="mb-3 flex items-center gap-2 print:mb-2">
                <Building2 size={16} className="text-brand-blue-800" />
                <h2 className="text-base font-semibold text-gray-900">{groupTitle}</h2>
                <span className="text-xs font-medium text-gray-500">({items.length} palata)</span>
              </header>
              <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 print:grid-cols-4">
                {items.map((q) => (
                  <QrCard key={q.room_id} item={q} />
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </Container>
  );
}

function QrCard({ item }) {
  return (
    <div className="flex flex-col items-center gap-2 rounded-xl border border-gray-100 bg-white p-3 shadow-sm transition hover:-translate-y-0.5 hover:border-brand-blue-100 hover:shadow-md print:break-inside-avoid print:shadow-none">
      <div className="rounded-lg bg-white p-2 ring-1 ring-gray-100">
        <QRCodeSVG
          value={item.qr_url}
          size={128}
          level="M"
          includeMargin={false}
          fgColor="#1e40af"
          bgColor="#ffffff"
        />
      </div>
      <div className="text-center">
        <div className="text-base font-bold text-gray-900">Palata {item.room_number}</div>
        <div className="text-[11px] font-medium text-gray-500">
          {item.hospital_short_name} • {item.floor_number}-qavat
        </div>
      </div>
    </div>
  );
}
