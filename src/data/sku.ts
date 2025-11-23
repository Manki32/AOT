export const skuMap = {
  chinese_map_quantity: 'M003CHIPOCKET',
  az_rack_card_quantity: 'RC001SPOOK',
  ostg_quantity: 'CP001',
  az_state_map_quantity: 'M001MAP2026',
} as const;

export type SKU = (typeof skuMap)[keyof typeof skuMap];
