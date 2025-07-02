import requests
import json
import time
from config import *

def get_recycling_points():
    """Get all recycling points from the map"""
    url = f"https://localizare.hartareciclarii.ro/@{LAT},{LON},{ZOOM}z"
    
    headers = {
        'accept': 'text/html, application/xhtml+xml',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9,ro;q=0.8,de;q=0.7',
        'map-bounds': MAP_BOUNDS,
        'priority': 'u=1, i',
        'referer': url,
        'sec-ch-ua': '"Google Chrome";v="137", "Chromium";v="137", "Not/A)Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
        'x-inertia': 'true',
        'x-inertia-partial-component': 'Map',
        'x-inertia-partial-data': 'points,filter',
        'x-inertia-version': '64a2a08ce5bd423830b934cbf0736761',
        'x-requested-with': 'XMLHttpRequest'
    }
    
    session = requests.Session()
    initial_response = session.get(url)
    
    if initial_response.status_code != 200:
        raise Exception(f"Failed to load initial page: {initial_response.status_code}")
    
    csrf_token = None
    for cookie in session.cookies:
        if cookie.name == 'XSRF-TOKEN':
            csrf_token = cookie.value
            break
    
    if csrf_token:
        headers['x-xsrf-token'] = csrf_token
    
    response = session.get(url, headers=headers)
    
    if response.status_code == 200:
        try:
            return response.json(), session
        except json.JSONDecodeError:
            raise Exception("Response is not valid JSON")
    else:
        raise Exception(f"Request failed with status code: {response.status_code}")

def get_point_details(point_id, session):
    """Get detailed information for a specific point"""
    url = f"https://localizare.hartareciclarii.ro/point/{point_id}"
    
    headers = {
        'accept': 'text/html, application/xhtml+xml',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9,ro;q=0.8,de;q=0.7',
        'priority': 'u=1, i',
        'sec-ch-ua': '"Google Chrome";v="137", "Chromium";v="137", "Not/A)Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
        'x-inertia': 'true',
        'x-inertia-partial-component': 'Map',
        'x-inertia-partial-data': 'context,point',
        'x-inertia-version': '64a2a08ce5bd423830b934cbf0736761',
        'x-requested-with': 'XMLHttpRequest'
    }
    
    # Get CSRF token from session cookies
    csrf_token = None
    for cookie in session.cookies:
        if cookie.name == 'XSRF-TOKEN':
            csrf_token = cookie.value
            break
    
    if csrf_token:
        headers['x-xsrf-token'] = csrf_token
    
    response = session.get(url, headers=headers)
    
    if response.status_code == 200:
        try:
            return response.json()
        except json.JSONDecodeError:
            raise Exception("Response is not valid JSON")
    else:
        raise Exception(f"Request failed with status code: {response.status_code}")

def extract_point_info(point_detail_data):
    """Extract only the required fields from point details"""
    if 'props' not in point_detail_data or 'point' not in point_detail_data['props']:
        return None
    
    point = point_detail_data['props']['point']
    
    # Extract materials - only the name from each material group
    materials = point.get('materials', [])
    material_names = []
    for material_group in materials:
        if isinstance(material_group, dict) and 'name' in material_group:
            material_names.append(material_group['name'])
    
    # Extract info - only offers_money
    info = point.get('info', {})
    simplified_info = {
        'offers_money': info.get('offers_money')
    }
    
    # Extract only the required fields with transformations
    extracted = {
        'id': point.get('id'),
        'name': point.get('name'),
        'latlng': point.get('latlng'),
        'subheading': point.get('subheading'),
        'address': point.get('address'),
        'materials': material_names,
        'info': simplified_info
    }
    
    return extracted

def get_all_points_with_details():
    """Main function to get all points and their details"""
    print("Starting to fetch all recycling points with details...")
    
    # Step 1: Get all points
    print("Step 1: Fetching all recycling points...")
    all_points_data, session = get_recycling_points()
    points = all_points_data.get('props', {}).get('points', [])
    
    print(f"Found {len(points)} points to process")
    
    # Step 2: Get details for each point
    detailed_points = []
    errors = []
    
    for i, point in enumerate(points):
        point_id = point['id']
        print(f"Processing point {i+1}/{len(points)}: ID {point_id}")
        
        try:
            # Get detailed information
            detail_data = get_point_details(point_id, session)
            extracted_info = extract_point_info(detail_data)
            
            if extracted_info:
                detailed_points.append(extracted_info)
                print(f"  ✓ Successfully processed point {point_id}")
            else:
                print(f"  ✗ Failed to extract info for point {point_id}")
                errors.append(point_id)
            
            # Add a small delay to be respectful to the server
            time.sleep(0.5)
            
        except Exception as e:
            print(f"  ✗ Error processing point {point_id}: {e}")
            errors.append(point_id)
            continue
    
    print(f"\nProcessing complete!")
    print(f"Successfully processed: {len(detailed_points)} points")
    print(f"Errors: {len(errors)} points")
    
    if errors:
        print(f"Failed point IDs: {errors}")
    
    return {
        'summary': {
            'total_points': len(points),
            'successful': len(detailed_points),
            'failed': len(errors),
            'failed_ids': errors
        },
        'points': detailed_points
    }

def save_detailed_points(data, filename="all_points_detailed.json"):
    """Save the detailed points data to a JSON file"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Data saved to {filename}")

def save_points_only(data, filename="points_only.json"):
    """Save only the points array (without summary) to a JSON file"""
    points_only = data.get('points', [])
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(points_only, f, indent=2, ensure_ascii=False)
    print(f"Points-only data saved to {filename}")

# Example usage
if __name__ == "__main__":
    try:
        # Get all points with their details
        result = get_all_points_with_details()
        
        # Save complete result (with summary)
        save_detailed_points(result, "all_points_detailed.json")
        
        # Save only the points array
        save_points_only(result, "points_only.json")
        
        # Print summary
        print(f"\n" + "="*50)
        print("FINAL SUMMARY")
        print("="*50)
        print(f"Total points found: {result['summary']['total_points']}")
        print(f"Successfully processed: {result['summary']['successful']}")
        print(f"Failed to process: {result['summary']['failed']}")
        
        if result['points']:
            print(f"\nFirst point example:")
            first_point = result['points'][0]
            print(f"  ID: {first_point['id']}")
            print(f"  Name: {first_point['name']}")
            print(f"  Address: {first_point['address']}")
            print(f"  Materials: {len(first_point.get('materials', []))} types")
        
    except Exception as e:
        print(f"Error: {e}")
