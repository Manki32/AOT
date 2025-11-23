import { skuMap } from 'src/data/sku';

export function buildItemsArray(formData: FormData): Item[] {
  return Object.entries(skuMap)
    .filter(([field]) => {
      const value = formData.get(field);
      return value !== null && value !== '' && Number(value) > 0;
    })
    .map(([field, sku]) => {
      const quantity = Number(formData.get(field));

      const baseItem = {
        sku,
        quantity,
        unitOfMeasure: 'Each',
      };

      if (sku === 'CP001') {
        return {
          ...baseItem,
          unitOfMeasure: 'Carton',
          eachesPercase: 50,
        } as Item;
      }

      return baseItem;
    });
}
