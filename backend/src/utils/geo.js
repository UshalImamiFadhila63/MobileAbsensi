const dotenv = require('dotenv');

// Menghitung jarak antara 2 koordinat (meter) pakai formula haversine
function hitungJarakMeter(lat1, lng1, lat2, lng2) {
  const R = 6371000; // radius bumi dalam meter
  const toRad = (deg) => (deg * Math.PI) / 180;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function isDalamRadiusKantor(lat, lng) {
  try {
    dotenv.config({ override: true });
  } catch (_) {}

  const officeLat = parseFloat(process.env.OFFICE_LAT || '-6.949161');
  const officeLng = parseFloat(process.env.OFFICE_LNG || '107.645018');
  const radius = parseFloat(process.env.OFFICE_RADIUS_METERS || '250');

  const jarak = hitungJarakMeter(lat, lng, officeLat, officeLng);
  return { valid: jarak <= radius, jarak };
}

module.exports = { hitungJarakMeter, isDalamRadiusKantor };
