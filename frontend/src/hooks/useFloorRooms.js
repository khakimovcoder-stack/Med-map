import { useQuery } from '@tanstack/react-query';
import { getFloorRooms } from '../api/endpoints.js';

export function useFloorRooms(floorId) {
  return useQuery({
    queryKey: ['floor-rooms', floorId],
    queryFn: () => getFloorRooms(floorId),
    enabled: Boolean(floorId),
  });
}
