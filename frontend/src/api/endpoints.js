import { apiClient } from './client.js';
import { HOSPITALS, findHospitalById, findFloorById, findRoomById } from './mockData.js';

const USE_MOCK = String(import.meta.env.VITE_USE_MOCK ?? 'true').toLowerCase() === 'true';

const MOCK_LATENCY_MS = 200;

function delay(ms = MOCK_LATENCY_MS) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function notFound(message) {
  const err = new Error(message);
  err.response = { status: 404, data: { error: { message } } };
  return err;
}

function shapeHospitalListItem(h) {
  return {
    id: h.id,
    name: h.name,
    short_name: h.short_name,
    city: h.city,
    region: h.region,
    address: h.address,
    phone: h.phone,
    latitude: h.latitude,
    longitude: h.longitude,
    total_beds: h.total_beds,
    available_beds: h.available_beds,
    floors_count: h.floors_count,
  };
}

function shapeHospitalDetail(h) {
  return {
    ...shapeHospitalListItem(h),
    floors: h.floors.map((f) => ({
      id: f.id,
      number: f.number,
      name: f.name,
      total_beds: f.total_beds,
      available_beds: f.available_beds,
    })),
  };
}

function shapeFloorRooms(hospital, floor) {
  return {
    floor: {
      id: floor.id,
      number: floor.number,
      name: floor.name,
      hospital: { id: hospital.id, name: hospital.short_name || hospital.name },
    },
    rooms: floor.rooms.map((r) => ({
      id: r.id,
      number: r.number,
      capacity: r.capacity,
      available_beds: r.available_beds,
      status_color: r.status_color,
      status_label: r.status_label,
      last_updated_at: r.last_updated_at,
      minutes_since_update: r.minutes_since_update,
    })),
  };
}

function shapeRoomDetail(hospital, floor, room) {
  const totalConfirmations = room.beds.reduce((acc, b) => acc + b.confirmation_count, 0);
  // Approximate unique users: confirmations / ~2 (each user confirms ~all beds at once)
  const uniqueUsers = Math.max(0, Math.round(totalConfirmations / 2));
  return {
    id: room.id,
    number: room.number,
    capacity: room.capacity,
    has_window: room.has_window,
    description: room.description,
    floor: { id: floor.id, number: floor.number, name: floor.name },
    hospital: {
      id: hospital.id,
      name: hospital.name,
      short_name: hospital.short_name,
    },
    available_beds: room.available_beds,
    total_beds: room.total_beds,
    beds: room.beds,
    confirmation_summary: {
      total_confirmations_24h: totalConfirmations,
      unique_users_24h: uniqueUsers,
      last_updated_at: room.last_updated_at,
      minutes_since_update: room.minutes_since_update,
    },
  };
}

function matchesSearch(hospital, query) {
  if (!query) return true;
  const q = query.trim().toLowerCase();
  return (
    hospital.name.toLowerCase().includes(q) ||
    (hospital.short_name || '').toLowerCase().includes(q) ||
    (hospital.city || '').toLowerCase().includes(q)
  );
}

// ---------- Public API ----------

export async function getHospitals({ search = '', city = '' } = {}) {
  if (USE_MOCK) {
    await delay();
    return HOSPITALS.filter((h) => matchesSearch(h, search))
      .filter((h) => (city ? h.city === city : true))
      .map(shapeHospitalListItem);
  }
  const params = {};
  if (search) params.search = search;
  if (city) params.city = city;
  return apiClient.get('/hospitals/', { params });
}

export async function getHospital(id) {
  if (USE_MOCK) {
    await delay();
    const h = findHospitalById(id);
    if (!h) throw notFound('Shifoxona topilmadi');
    return shapeHospitalDetail(h);
  }
  return apiClient.get(`/hospitals/${id}/`);
}

export async function getHospitalFloors(id) {
  if (USE_MOCK) {
    await delay();
    const h = findHospitalById(id);
    if (!h) throw notFound('Shifoxona topilmadi');
    return h.floors.map((f) => ({
      id: f.id,
      number: f.number,
      name: f.name,
      total_beds: f.total_beds,
      available_beds: f.available_beds,
      rooms_count: f.rooms_count,
    }));
  }
  return apiClient.get(`/hospitals/${id}/floors/`);
}

export async function getFloorRooms(floorId) {
  if (USE_MOCK) {
    await delay();
    const found = findFloorById(floorId);
    if (!found) throw notFound('Qavat topilmadi');
    return shapeFloorRooms(found.hospital, found.floor);
  }
  return apiClient.get(`/floors/${floorId}/rooms/`);
}

export async function getRoom(roomId) {
  if (USE_MOCK) {
    await delay();
    const found = findRoomById(roomId);
    if (!found) throw notFound('Palata topilmadi');
    return shapeRoomDetail(found.hospital, found.floor, found.room);
  }
  return apiClient.get(`/rooms/${roomId}/`);
}

export async function getQrCodes({ hospitalId } = {}) {
  if (USE_MOCK) {
    await delay();
    return HOSPITALS.flatMap((h) =>
      h.floors.flatMap((f) =>
        f.rooms.map((r) => ({
          room_id: r.id,
          room_number: r.number,
          floor_number: f.number,
          hospital_id: h.id,
          hospital_short_name: h.short_name || h.name,
          qr_code_token: r.id.replace(/-/g, ''),
          qr_url: `https://medmap.uz/r/${r.id.replace(/-/g, '')}`,
        })),
      ),
    ).filter((x) => (hospitalId ? x.hospital_id === hospitalId : true));
  }
  const params = {};
  if (hospitalId) params.hospital_id = hospitalId;
  return apiClient.get('/qr-codes/', { params });
}
