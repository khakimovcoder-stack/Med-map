import { DoorOpen } from 'lucide-react';
import BedTile from './BedTile.jsx';

// 2D top-down view of a 4-bed room: window strip on top, beds in 2x2 grid,
// door at the bottom. Beds at positions 1-2 are near the window.
export default function RoomVisual2D({ beds }) {
  // Defensive: ensure 4 positions, sorted
  const sorted = [...(beds || [])].sort((a, b) => a.position - b.position);

  return (
    <div className="relative rounded-2xl border border-gray-200 bg-gradient-to-b from-brand-blue-50/40 via-white to-gray-50 p-5 shadow-card sm:p-7">
      {/* Window */}
      <div className="mb-5">
        <div
          className="window-bar h-2.5 w-full rounded-full shadow-[inset_0_1px_2px_rgba(255,255,255,0.5)]"
          aria-hidden="true"
        />
        <p className="mt-1.5 text-center text-[11px] font-semibold uppercase tracking-[0.2em] text-brand-blue-800">
          Deraza
        </p>
      </div>

      {/* Beds 2x2 */}
      <div className="grid grid-cols-2 gap-4 sm:gap-5">
        {sorted.map((bed) => (
          <BedTile key={bed.id || bed.position} bed={bed} />
        ))}
      </div>

      {/* Door */}
      <div className="mt-6 flex flex-col items-center">
        <div className="flex h-3 w-32 items-center justify-center rounded-full bg-gray-200" aria-hidden="true" />
        <div className="mt-1 flex items-center gap-1 text-[11px] font-semibold uppercase tracking-[0.2em] text-gray-500">
          <DoorOpen size={11} aria-hidden="true" />
          Eshik
        </div>
      </div>
    </div>
  );
}
