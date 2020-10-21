import csv

class CSVDigester:

    def __init__(self, name, filepath, max_buffer_size=1000):
        self.name = name
        self.filepath = filepath
        self.fout = open(filepath, "w")
        self.writer = csv.writer(self.fout, delimiter=";")
        self.max_buffer_size = max_buffer_size
        self.buffer = []
        self.writer.writerow(self.header())
    
    def __enter__(self):
        return self
    
    def __exit__(self, type, value, traceback):
        self.close()
    
    def header(self):
        raise NotImplementedError("You must overwrite this method")
    
    def row(self, *data):
        raise NotImplementedError("You must overwrite this method")
    
    def add(self, *data):
        if len(self.buffer) >= self.max_buffer_size:
            self.flush()
        
        self.buffer.append(self.row(*data))

    def flush(self):
        for item in self.buffer:
            self.writer.writerow(item)
        self.buffer.clear()
        print("Flushed", self.name)
    
    def close(self):
        self.flush()
        self.fout.close()
        print("Closed", self.name)


class CSVFileDigester(CSVDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("CSVFileDigester", filepath, max_buffer_size)
    
    def header(self):
        return ["_id", "uuid", "hostname", "path", "created_at", "b64image"]
    
    def row(self, data):
        return [
            str(data["_id"]),
            data["uuid"],
            data["hostname"],
            data["path"],
            data["created_at"],
            data["b64image"]
        ]


class CSVFaceDigester(CSVDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("CSVFaceDigester", filepath, max_buffer_size)
    
    def header(self):
        return [
            "uuid", 
            "file_id", 
            "confidence", 
            "rect1", "rect2", "rect3", "rect4", 
            "p1x", "p2x", "p3x", "p4x", "p5x", 
            "p1y", "p2y", "p3y", "p4y", "p5y", 
            "b64image"
        ]
    
    def row(self, file_id, data):
        uuid = data["uuid"] if "uuid" in data else ""
        r = data["rect"]
        p1 = data["p1"]
        p2 = data["p2"]
        p3 = data["p3"]
        p4 = data["p4"]
        p5 = data["p5"]
        
        return [
            uuid,
            file_id,
            data["confidence"],
            r[0], r[1], r[2], r[3],
            p1[0], p2[0], p3[0], p4[0], p5[0],
            p1[1], p2[1], p3[1], p4[1], p5[1],
            data["b64image"]
        ]


class CSVLicensePlateDigester(CSVDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("CSVLicensePlateDigester", filepath, max_buffer_size)
    
    def header(self):
        return [
            "uuid", 
            "file_id", 
            "r0", "r1", "r2", "r3", 
            "b64image", 
            "p1", "p2", "p3", 
            "c1", "c2", "c3", 
        ]
    
    def row(self, file_id, data):
        return [
            data["uuid"], 
            file_id, 
            data["rect"][0], data["rect"][1], data["rect"][2], data["rect"][3], 
            data["b64image"], 
            data["p1"], data["p2"], data["p3"], 
            data["c1"], data["c2"], data["c3"]
        ]
