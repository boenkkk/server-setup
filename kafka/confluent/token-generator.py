import jwt
import datetime

def generate_token(private_key_path, user_id, role):
    with open(private_key_path, 'r') as file:
        private_key = file.read()

    payload = {
        'sub': user_id,
        'role': role,
        'iat': datetime.datetime.utcnow(),
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)
    }

    token = jwt.encode(payload, private_key, algorithm='RS256')
    return token

# Usage
token = generate_token('private-key.pem', 'user123', 'admin')
print(f"Bearer {token}")

# eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyMTIzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM5Mzg0ODM1LCJleHAiOjE3Mzk0NzEyMzV9.1B6vZ4vqrJNhVbCtM9yFS76sJwq5RfFisS2zRYDipxNNh-a6Tn4hZhLkyqxJF1_vImLTNakE5xu0GzmWM5HSJFBkEIUhKUMOBF5JEJPoRs9y2esEUI8OFCLh5zfR217s0zzPkFib7a5L_AOPgcARk2OP3U70Li9GZHBieEqYo1V4ebxrtK4w20iYk0xJAJ_vQLTz86696xS3bejVCY1n0mCwMkKfCd2vAfVsdwL0NVC31OJNxEBfs2Tnz6sxSG4aoahh_z-SE-E_no35NShSxWxz8cWAoFaRXNRJ2QyyVkpecQ_yS8MxubpPnJ4tqHcajoR-rxi7N1jxFe4bo56z4A
# curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyMTIzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM5Mzg0ODM1LCJleHAiOjE3Mzk0NzEyMzV9.1B6vZ4vqrJNhVbCtM9yFS76sJwq5RfFisS2zRYDipxNNh-a6Tn4hZhLkyqxJF1_vImLTNakE5xu0GzmWM5HSJFBkEIUhKUMOBF5JEJPoRs9y2esEUI8OFCLh5zfR217s0zzPkFib7a5L_AOPgcARk2OP3U70Li9GZHBieEqYo1V4ebxrtK4w20iYk0xJAJ_vQLTz86696xS3bejVCY1n0mCwMkKfCd2vAfVsdwL0NVC31OJNxEBfs2Tnz6sxSG4aoahh_z-SE-E_no35NShSxWxz8cWAoFaRXNRJ2QyyVkpecQ_yS8MxubpPnJ4tqHcajoR-rxi7N1jxFe4bo56z4A" http://localhost:8081/subjects
# curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyMTIzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzM5Mzg0ODM1LCJleHAiOjE3Mzk0NzEyMzV9.1B6vZ4vqrJNhVbCtM9yFS76sJwq5RfFisS2zRYDipxNNh-a6Tn4hZhLkyqxJF1_vImLTNakE5xu0GzmWM5HSJFBkEIUhKUMOBF5JEJPoRs9y2esEUI8OFCLh5zfR217s0zzPkFib7a5L_AOPgcARk2OP3U70Li9GZHBieEqYo1V4ebxrtK4w20iYk0xJAJ_vQLTz86696xS3bejVCY1n0mCwMkKfCd2vAfVsdwL0NVC31OJNxEBfs2Tnz6sxSG4aoahh_z-SE-E_no35NShSxWxz8cWAoFaRXNRJ2QyyVkpecQ_yS8MxubpPnJ4tqHcajoR-rxi7N1jxFe4bo56z4A" http://localhost:8083/connectors