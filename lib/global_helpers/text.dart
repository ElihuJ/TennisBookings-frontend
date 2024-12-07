String capitalizeFirstLetter(String string) {
  if (string.isEmpty) {
    return string;
  }
  return string[0].toUpperCase() + string.substring(1);
}

const naString = 'N/A';
