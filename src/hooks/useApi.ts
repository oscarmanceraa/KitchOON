import { useState, useEffect, useCallback } from 'react';

interface UseApiDataResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

/**
 * Hook personalizado para manejar peticiones a la API
 * @param fetcher - Función que retorna una Promise con los datos
 * @param dependencies - Array de dependencias para re-ejecutar el fetcher
 * @returns Objeto con data, loading, error y función refetch
 */
export function useApiData<T>(
  fetcher: () => Promise<T>,
  dependencies: any[] = []
): UseApiDataResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await fetcher();
      setData(result);
    } catch (err) {
      setError(err as Error);
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  }, [fetcher]);

  useEffect(() => {
    fetchData();
  }, [...dependencies, fetchData]);

  return {
    data,
    loading,
    error,
    refetch: fetchData,
  };
}

interface UseMutationResult<TData, TVariables> {
  mutate: (variables: TVariables) => Promise<TData>;
  loading: boolean;
  error: Error | null;
  data: TData | null;
}

/**
 * Hook para manejar mutaciones (POST, PUT, DELETE, PATCH)
 * @param mutationFn - Función que ejecuta la mutación
 * @returns Objeto con mutate, loading, error y data
 */
export function useMutation<TData = any, TVariables = any>(
  mutationFn: (variables: TVariables) => Promise<TData>
): UseMutationResult<TData, TVariables> {
  const [data, setData] = useState<TData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const mutate = async (variables: TVariables): Promise<TData> => {
    try {
      setLoading(true);
      setError(null);
      const result = await mutationFn(variables);
      setData(result);
      return result;
    } catch (err) {
      const error = err as Error;
      setError(error);
      console.error('Mutation error:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return {
    mutate,
    loading,
    error,
    data,
  };
}
