// Category interface based on your API response
export interface Category {
  id: number;
  created_at: string; // timestamp as an ISO string
  name: string;
  slug: string;
  wf_id: string;
  Addon: string;
}

export async function fetchAllCategories(): Promise<Category[]> {
  const url = 'https://x7jb-b5dw-kwm6.n7e.xano.io/api:ZrH1twVu/categories';

  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data: Category[] = await response.json();
    return data;
  } catch (error) {
    console.error('Failed fetching categories:', error);
    throw error;
  }
}
