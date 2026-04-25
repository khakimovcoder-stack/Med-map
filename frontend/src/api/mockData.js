// Mock seed for offline UI development. Mirrors the API contract shape.
// Topology: 3 hospitals × 4 floors × 10 rooms × 4 beds = 480 beds total.

const STATUSES = ['BAND', 'BOSH', 'NOMALUM'];

// Deterministic pseudo-random so the UI is stable across reloads.
function seededRandom(seed) {
  let state = seed >>> 0;
  return () => {
    state = (state * 1664525 + 1013904223) >>> 0;
    return state / 0xffffffff;
  };
}

function pickStatus(rand) {
  // Distribution: 60% BAND, 30% BOSH, 10% NOMALUM (per data models)
  const r = rand();
  if (r < 0.6) return 'BAND';
  if (r < 0.9) return 'BOSH';
  return 'NOMALUM';
}

const HOSPITALS_SEED = [
  {
    id: 'hosp-rikm',
    name: 'Respublika Ixtisoslashtirilgan Kardiologiya Markazi',
    short_name: 'RIKM',
    city: 'Toshkent',
    region: 'Toshkent shahri',
    address: 'Toshkent sh., Yunusobod tumani, A. Qodiriy 4',
    phone: '+998712345678',
    latitude: 41.311081,
    longitude: 69.240562,
  },
  {
    id: 'hosp-svktm',
    name: "Samarqand Viloyat Ko'p Tarmoqli Tibbiy Markazi",
    short_name: 'SVKTM',
    city: 'Samarqand',
    region: 'Samarqand viloyati',
    address: 'Samarqand sh., Universitet xiyoboni 18',
    phone: '+998662345678',
    latitude: 39.654047,
    longitude: 66.975853,
  },
  {
    id: 'hosp-bvsh',
    name: "Buxoro Viloyat Sho'ba Shifoxonasi",
    short_name: 'BVSh',
    city: 'Buxoro',
    region: 'Buxoro viloyati',
    address: "Buxoro sh., Mustaqillik ko'chasi 5",
    phone: '+998652345678',
    latitude: 39.767433,
    longitude: 64.421825,
  },
];

const FLOOR_NAMES = ['Qabulxona qavati', 'Davolanish qavati', 'Reanimatsiya qavati', 'Kuzatuv qavati'];

function buildBed(roomId, position, rand) {
  const isNearWindow = position === 1 || position === 2;
  const status = pickStatus(rand);
  const minutesAgo = Math.floor(rand() * 180); // up to 3 hours ago
  const lastConfirmedAt =
    status === 'NOMALUM' && rand() < 0.5
      ? null
      : new Date(Date.now() - minutesAgo * 60 * 1000).toISOString();
  return {
    id: `${roomId}-bed-${position}`,
    position,
    is_near_window: isNearWindow,
    current_status: status,
    last_confirmed_at: lastConfirmedAt,
    confirmation_count: status === 'NOMALUM' ? 0 : 1 + Math.floor(rand() * 3),
  };
}

function buildRoom(floorNumber, roomIndex, hospitalId, floorId, rand) {
  const number = `${floorNumber}${String(roomIndex + 1).padStart(2, '0')}`;
  const id = `${floorId}-room-${number}`;
  const beds = Array.from({ length: 4 }, (_, i) => buildBed(id, i + 1, rand));
  const availableBeds = beds.filter((b) => b.current_status === 'BOSH').length;
  const knownBeds = beds.filter((b) => b.current_status !== 'NOMALUM').length;

  let statusColor = 'gray';
  let statusLabel = "Noma'lum";
  if (knownBeds > 0) {
    if (availableBeds === 0) {
      statusColor = 'red';
      statusLabel = "To'liq band";
    } else {
      statusColor = 'green';
      statusLabel = `${availableBeds} bo'sh`;
    }
  }

  const lastTimes = beds
    .map((b) => b.last_confirmed_at)
    .filter(Boolean)
    .map((t) => new Date(t).getTime());
  const lastUpdatedAt = lastTimes.length ? new Date(Math.max(...lastTimes)).toISOString() : null;
  const minutesSinceUpdate = lastUpdatedAt
    ? Math.max(0, Math.round((Date.now() - new Date(lastUpdatedAt).getTime()) / 60000))
    : null;

  return {
    id,
    floorId,
    hospitalId,
    number,
    capacity: 4,
    has_window: true,
    description: null,
    qr_code_token: `qr-${id}`,
    available_beds: availableBeds,
    total_beds: 4,
    status_color: statusColor,
    status_label: statusLabel,
    last_updated_at: lastUpdatedAt,
    minutes_since_update: minutesSinceUpdate,
    beds,
  };
}

function buildFloor(hospitalId, floorNumber, hospitalIndex) {
  const id = `${hospitalId}-floor-${floorNumber}`;
  const rand = seededRandom(hospitalIndex * 1000 + floorNumber * 17);
  const rooms = Array.from({ length: 10 }, (_, i) =>
    buildRoom(floorNumber, i, hospitalId, id, rand),
  );
  const totalBeds = rooms.reduce((acc, r) => acc + r.total_beds, 0);
  const availableBeds = rooms.reduce((acc, r) => acc + r.available_beds, 0);
  return {
    id,
    hospitalId,
    number: floorNumber,
    name: FLOOR_NAMES[floorNumber - 1] || null,
    total_beds: totalBeds,
    available_beds: availableBeds,
    rooms_count: rooms.length,
    rooms,
  };
}

function buildHospital(seed, hospitalIndex) {
  const floors = Array.from({ length: 4 }, (_, i) =>
    buildFloor(seed.id, i + 1, hospitalIndex),
  );
  const totalBeds = floors.reduce((acc, f) => acc + f.total_beds, 0);
  const availableBeds = floors.reduce((acc, f) => acc + f.available_beds, 0);
  return {
    ...seed,
    total_beds: totalBeds,
    available_beds: availableBeds,
    floors_count: floors.length,
    floors,
  };
}

// Build once at module load — keep across the session for stable navigation.
export const HOSPITALS = HOSPITALS_SEED.map((seed, idx) => buildHospital(seed, idx));

export function findHospitalById(id) {
  return HOSPITALS.find((h) => h.id === id) || null;
}

export function findFloorById(id) {
  for (const hospital of HOSPITALS) {
    for (const floor of hospital.floors) {
      if (floor.id === id) return { hospital, floor };
    }
  }
  return null;
}

export function findRoomById(id) {
  for (const hospital of HOSPITALS) {
    for (const floor of hospital.floors) {
      for (const room of floor.rooms) {
        if (room.id === id) return { hospital, floor, room };
      }
    }
  }
  return null;
}
