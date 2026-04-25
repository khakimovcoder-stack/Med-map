import { useQuery } from '@tanstack/react-query';
import { getRoom } from '../api/endpoints.js';

export function useRoom(roomId) {
  return useQuery({
    queryKey: ['room', roomId],
    queryFn: () => getRoom(roomId),
    enabled: Boolean(roomId),
  });
}
