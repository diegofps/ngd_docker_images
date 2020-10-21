import pyarrow.parquet as pq
import pyarrow as pa
import pandas as pd
import numpy as np


class ParquetDigester:

    def __init__(self, name, filepath, max_buffer_size=1000):
        self.name = name
        self.filepath = filepath
        self.max_buffer_size = max_buffer_size
        self._headers = self.headers()
        self.columns = {name:[] for name in self._headers}
        self.counter = 0
        self.writer = None
    
    def __enter__(self):
        return self
    
    def __exit__(self, type, value, traceback):
        self.close()
    
    def headers(self):
        raise NotImplementedError("You must overwrite this method")
    
    def row(self, *data):
        raise NotImplementedError("You must overwrite this method")
    
    def add(self, *data):
        if self.counter >= self.max_buffer_size:
            self.flush()
        
        self.digest(self.columns, *data)
        self.counter += 1

    def digest(self, columns, data):
        for item in self._headers:
            columns[item].append(data[item])

    def flush(self):
        if self.counter == 0:
            print("Flushed", self.name, "skipped")
            return
        
        df = pd.DataFrame(self.columns)
        table = pa.Table.from_pandas(df)
        
        if self.writer is None:
            self.writer = pq.ParquetWriter(self.filepath, table.schema)
        
        self.writer.write_table(table=table)
        
        self.counter = 0
        for v in self.columns.values():
            v.clear()
        
        print("Flushed", self.name)
    
    def close(self):
        self.flush()
        
        if self.writer:
            self.writer.close()
        
        print("Closed", self.name)


class ParquetFileDigester(ParquetDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("FileParquetDigester", filepath, max_buffer_size)
    
    def headers(self):
        return ["_id", "uuid", "hostname", "path", "created_at", "b64image"]
    

class ParquetFaceDigester(ParquetDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("FaceDigester", filepath, max_buffer_size)
    
    def headers(self):
        return [
            "uuid", 
            "file_id", 
            "confidence", 
            "rect1", "rect2", "rect3", "rect4", 
            "p1x", "p2x", "p3x", "p4x", "p5x", 
            "p1y", "p2y", "p3y", "p4y", "p5y", 
            "b64image"
        ]
    
    def digest(self, cols, file_id, data):
        uuid = data["uuid"] if "uuid" in data else ""
        r = data["rect"]
        p1 = data["p1"]
        p2 = data["p2"]
        p3 = data["p3"]
        p4 = data["p4"]
        p5 = data["p5"]
        
        cols["uuid"].append(uuid)
        cols["file_id"].append(file_id)
        cols["confidence"].append(data["confidence"])
        cols["rect1"].append(r[0])
        cols["rect2"].append(r[1])
        cols["rect3"].append(r[2])
        cols["rect4"].append(r[3])
        cols["p1x"].append(p1[0])
        cols["p2x"].append(p2[0])
        cols["p3x"].append(p3[0])
        cols["p4x"].append(p4[0])
        cols["p5x"].append(p5[0])
        cols["p1y"].append(p1[1])
        cols["p2y"].append(p2[1])
        cols["p3y"].append(p3[1])
        cols["p4y"].append(p4[1])
        cols["p5y"].append(p5[1])
        cols["b64image"].append(str(data["b64image"]))


class ParquetLicensePlateDigester(ParquetDigester):

    def __init__(self, filepath, max_buffer_size=1000):
        super().__init__("FaceDigester", filepath, max_buffer_size)
    
    def headers(self):
        return [
            "uuid", 
            "file_id", 
            "r0", "r1", "r2", "r3", 
            "b64image", 
            "p1", "p2", "p3", 
            "c1", "c2", "c3", 
        ]
    
    def digest(self, cols, file_id, data):
        uuid = data["uuid"] if "uuid" in data else ""
        r = data["rect"]
        
        cols["uuid"].append(uuid)
        cols["file_id"].append(file_id)
        cols["r0"].append(r[0])
        cols["r1"].append(r[1])
        cols["r2"].append(r[2])
        cols["r3"].append(r[3])
        cols["b64image"].append(data["b64image"])
        cols["p1"].append(data["p1"])
        cols["p2"].append(data["p2"])
        cols["p3"].append(data["p3"])
        cols["c1"].append(data["c1"])
        cols["c2"].append(data["c2"])
        cols["c3"].append(data["c3"])

